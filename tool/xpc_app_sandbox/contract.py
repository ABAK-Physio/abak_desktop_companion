"""Compare measured kernel permissions; never infer safety from entitlements alone."""
import errno


def _denied(probe):
    return isinstance(probe, dict) and probe.get("allowed") is False and probe.get("errno") in (errno.EPERM, errno.EACCES)


def assess(report):
    failures = []
    if report.get("syntheticOnly") is not True or report.get("childExit") != 0:
        failures.append("native_probe_incomplete")
    for actor in ("service", "child"):
        data = report.get(actor, {})
        if data.get("privateWorkWrite", {}).get("allowed") is not True:
            failures.append(actor + ":private_work_unavailable")
        for field in ("network", "callerWrite", "outsideWorkWrite"):
            if not _denied(data.get(field)):
                failures.append(actor + ":" + field + "_not_proven_denied")
        if data.get("callerRead", {}).get("allowed") is not True:
            failures.append(actor + ":input_transfer_required")
    # These require their own signed real-engine and authentication recipes.
    failures += ["cps_and_iokit_equivalence_not_verified",
                 "pdfa_cda_docx_engines_not_verified",
                 "xpc_peer_rejection_not_verified"]
    return {"readyForProduction": False, "gaps": failures,
            "decision": "KEEP_EXISTING_PRODUCTION_SANDBOX"}
