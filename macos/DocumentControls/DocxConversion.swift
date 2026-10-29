import Foundation
import Security
import CryptoKit
import Darwin

extension Worker {
    // Official, locally configured engine; no caller-supplied command or shared Office
    // profile. The service's network/write/CPS restrictions remain in force.
    func convertDocx(_ value: [String:Any]) throws -> Data {
        guard Set(value.keys) == ["protocol","operation","job","sourceHash","office"],
              let jobPath = value["job"] as? String,
              let expected = value["sourceHash"] as? String,
              let officePath = value["office"] as? String else { throw fail("Conversion DOCX invalide") }
        let job = try regular(jobPath, directory:true)
        let source = try regular(job.appendingPathComponent("source.docx").path)
        guard (try source.resourceValues(forKeys:[.fileSizeKey]).fileSize ?? Int.max) <= 20*1024*1024,
              try fileDigest(source) == expected else { throw fail("DOCX modifié avant conversion") }
        let app = try regular(officePath, directory:true)
        var code: SecStaticCode?, requirement: SecRequirement?
        guard SecStaticCodeCreateWithPath(app as CFURL, [], &code) == errSecSuccess,
              let code,
              SecRequirementCreateWithString("anchor apple generic and identifier \"org.libreoffice.script\" and certificate leaf[subject.OU] = \"7P5S3ZLCN7\"" as CFString, [], &requirement) == errSecSuccess,
              SecStaticCodeCheckValidity(code, SecCSFlags(rawValue:kSecCSStrictValidate | kSecCSCheckAllArchitectures), requirement) == errSecSuccess,
              let version = Bundle(url:app)?.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String else {
            throw fail("LibreOffice officiel absent ou signature non vérifiée. Vérifiez la copie configurée.")
        }
        let executable = try regular(app.appendingPathComponent("Contents/MacOS/soffice").path)
        let scratch = work.appendingPathComponent(UUID().uuidString, isDirectory:true)
        try fm.createDirectory(at:scratch,withIntermediateDirectories:false)
        defer { try? fm.removeItem(at:scratch) }
        let input = scratch.appendingPathComponent("source.docx")
        try fm.copyItem(at:source,to:input)
        guard try fileDigest(input) == expected else { throw fail("Copie DOCX différente") }
        let profile = scratch.appendingPathComponent("office",isDirectory:true)
        let user = profile.appendingPathComponent("user",isDirectory:true)
        try fm.createDirectory(at:user,withIntermediateDirectories:true)
        try Data("""
        <?xml version="1.0" encoding="UTF-8"?>
        <oor:items xmlns:oor="http://openoffice.org/2001/registry">
          <item oor:path="/org.openoffice.Office.Common/Security/Scripting"><prop oor:name="DisableMacrosExecution" oor:op="fuse"><value>true</value></prop><prop oor:name="MacroSecurityLevel" oor:op="fuse"><value>3</value></prop></item>
          <item oor:path="/org.openoffice.Office.Writer/Content/Update"><prop oor:name="Link" oor:op="fuse"><value>2</value></prop></item>
        </oor:items>
        """.utf8).write(to:user.appendingPathComponent("registrymodifications.xcu"))
        let process = Process()
        process.executableURL = executable
        process.arguments = ["-env:UserInstallation="+profile.absoluteString,"-env:OSL_SOCKET_PATH="+work.path,"--headless","--nologo","--nodefault","--norestore","--nolockcheck","--convert-to",
            "pdf:writer_pdf_Export:{\"SelectPdfVersion\":{\"type\":\"long\",\"value\":\"1\"},\"UseTaggedPDF\":{\"type\":\"boolean\",\"value\":\"true\"},\"ExportFormFields\":{\"type\":\"boolean\",\"value\":\"false\"},\"ExportNotes\":{\"type\":\"boolean\",\"value\":\"false\"}}",
            "--outdir",scratch.path,input.path]
        process.currentDirectoryURL = scratch
        process.environment = ["PATH":"/usr/bin:/bin","HOME":scratch.path,"TMPDIR":work.path,"SAL_USE_VCLPLUGIN":"svp","PYTHONDONTWRITEBYTECODE":"1"]
        let output = Pipe(), errors = Pipe()
        process.standardOutput=output; process.standardError=errors; process.standardInput=FileHandle.nullDevice
        lock.lock()
        if cancelled { lock.unlock(); throw fail("Conversion annulée") }
        child=process
        do { try process.run() } catch { child=nil; lock.unlock(); throw error }
        lock.unlock()
        let group=DispatchGroup(), out=Capture(), err=Capture()
        group.enter(); DispatchQueue.global().async { out.read(output.fileHandleForReading,process:process); group.leave() }
        group.enter(); DispatchQueue.global().async { err.read(errors.fileHandleForReading,process:process); group.leave() }
        let timer=DispatchSource.makeTimerSource(queue:DispatchQueue.global())
        timer.schedule(deadline:.now()+120)
        timer.setEventHandler { if process.isRunning { kill(process.processIdentifier,SIGKILL) } }
        timer.resume(); process.waitUntilExit(); timer.cancel(); group.wait()
        lock.lock(); child=nil; let stopped=cancelled; lock.unlock()
        guard !stopped, !out.exceeded, !err.exceeded, process.terminationStatus == 0 else { throw fail("Conversion DOCX interrompue ou impossible (code \(process.terminationStatus)). Le DOCX est conservé.") }
        let result=try regular(scratch.appendingPathComponent("source.pdf").path)
        guard (try result.resourceValues(forKeys:[.fileSizeKey]).fileSize ?? Int.max) <= 20*1024*1024 else { throw fail("PDF produit trop volumineux") }
        let pdf=try Data(contentsOf:result)
        guard pdf.starts(with:Data("%PDF-".utf8)), try fileDigest(source) == expected else { throw fail("PDF absent ou DOCX modifié") }
        return try JSONSerialization.data(withJSONObject:[
            "protocol":1,"operation":"docx","pdf":pdf.base64EncodedString(),
            "sourceHash":expected,"pdfHash":try fileDigest(result),"engine":"LibreOffice",
            "engineVersion":version,"engineHash":try fileDigest(executable),
            "engineSignatureVerified":true,"profile":"PDF/A-1b requested; independent validation required",
            "networkDenied":true,"privateProfile":true,"macrosDisabled":true,"policySha256":policyHash
        ])
    }
}
