#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include <flutter/standard_method_codec.h>
#include <winscard.h>

#include <vector>

#pragma comment(lib, "Winscard.lib")
#include <string>
#include <iomanip>
#include <sstream>
#include <windows.h>

using HnInitFunction = unsigned short (*)(
        const unsigned char* pcChemin,
        unsigned short* pusMode,
        unsigned short* pusCodeErreur);

using HnReadVitaleIdentityFunction = unsigned short (*)(
        short sTempsAttente,
        char* pcDataOut,
        unsigned int* puiLgDataOut,
        short* psEtatCarte,
        unsigned short* pusCodeErreur);

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
        : project_(project) {}

FlutterWindow::~FlutterWindow() {}

static flutter::EncodableMap GetSmartCardStatus() {
    flutter::EncodableMap response;

    bool reader_detected = false;
    bool card_detected = false;

    response[flutter::EncodableValue("readerDetected")] =
            flutter::EncodableValue(reader_detected);

    response[flutter::EncodableValue("cardDetected")] =
            flutter::EncodableValue(card_detected);

    SCARDCONTEXT context = 0;

    LONG status = SCardEstablishContext(
            SCARD_SCOPE_USER,
            nullptr,
            nullptr,
            &context);

    if (status != SCARD_S_SUCCESS) {
        response[flutter::EncodableValue("error")] =
                flutter::EncodableValue(
                        "SCardEstablishContext failed: " +
                        std::to_string(status));

        return response;
    }

    DWORD readers_length = 0;

    status = SCardListReadersA(
            context,
            nullptr,
            nullptr,
            &readers_length);

    if (status == SCARD_E_NO_READERS_AVAILABLE) {
        SCardReleaseContext(context);
        return response;
    }

    if (status != SCARD_S_SUCCESS) {
        response[flutter::EncodableValue("error")] =
                flutter::EncodableValue(
                        "SCardListReaders length failed: " +
                        std::to_string(status));

        SCardReleaseContext(context);
        return response;
    }

    std::vector<char> readers(readers_length);

    status = SCardListReadersA(
            context,
            nullptr,
            readers.data(),
            &readers_length);

    if (status == SCARD_S_SUCCESS &&
        !readers.empty() &&
        readers[0] != '\0') {

        reader_detected = true;

        response[flutter::EncodableValue("readerDetected")] =
                flutter::EncodableValue(reader_detected);

        response[flutter::EncodableValue("readerName")] =
                flutter::EncodableValue(std::string(readers.data()));

        // ---------------------------------------------------------
        // Détection de la présence de la carte
        // ---------------------------------------------------------

        SCARDHANDLE card_handle = 0;
        DWORD active_protocol = 0;

        status = SCardConnectA(
                context,
                readers.data(),
                SCARD_SHARE_SHARED,
                SCARD_PROTOCOL_T0 | SCARD_PROTOCOL_T1,
                &card_handle,
                &active_protocol);

        if (status == SCARD_S_SUCCESS) {

            card_detected = true;

            response[flutter::EncodableValue("cardDetected")] =
                    flutter::EncodableValue(card_detected);

            char reader_name[256];
            DWORD reader_name_length = sizeof(reader_name);

            DWORD state = 0;
            DWORD protocol = 0;

            BYTE atr[64];
            DWORD atr_length = sizeof(atr);

            status = SCardStatusA(
                    card_handle,
                    reader_name,
                    &reader_name_length,
                    &state,
                    &protocol,
                    atr,
                    &atr_length);

            if (status == SCARD_S_SUCCESS) {

                std::ostringstream stream;
                stream << std::uppercase << std::hex << std::setfill('0');

                for (DWORD i = 0; i < atr_length; ++i) {
                    if (i > 0)
                        stream << ' ';
                    stream << std::setw(2) << static_cast<int>(atr[i]);
                }

                response[flutter::EncodableValue("atr")] =
                        flutter::EncodableValue(stream.str());
            }

            SCardDisconnect(card_handle, SCARD_LEAVE_CARD);

        } else if (status != SCARD_E_NO_SMARTCARD &&
                   status != SCARD_W_REMOVED_CARD) {

            response[flutter::EncodableValue("error")] =
                    flutter::EncodableValue(
                            "SCardConnect failed: " +
                            std::to_string(status));
        }

    } else if (status != SCARD_E_NO_READERS_AVAILABLE) {

        response[flutter::EncodableValue("error")] =
                flutter::EncodableValue(
                        "SCardListReaders failed: " +
                        std::to_string(status));
    }

    SCardReleaseContext(context);

    return response;
}

static bool TransmitApdu(
        SCARDHANDLE card,
        const SCARD_IO_REQUEST* pci,
        const BYTE* command,
        DWORD command_length,
        std::vector<BYTE>& response) {

    BYTE receive_buffer[258];
    DWORD receive_length = sizeof(receive_buffer);

    LONG status = SCardTransmit(
            card,
            pci,
            command,
            command_length,
            nullptr,
            receive_buffer,
            &receive_length);

    if (status != SCARD_S_SUCCESS) {
        return false;
    }

    response.assign(
            receive_buffer,
            receive_buffer + receive_length);

    // Gestion automatique de GET RESPONSE
    if (response.size() == 2 &&
        response[0] == 0x61) {

        BYTE get_response[] = {
                0x00,
                0xC0,
                0x00,
                0x00,
                response[1]
        };

        receive_length = sizeof(receive_buffer);

        status = SCardTransmit(
                card,
                pci,
                get_response,
                sizeof(get_response),
                nullptr,
                receive_buffer,
                &receive_length);

        if (status != SCARD_S_SUCCESS) {
            return false;
        }

        response.assign(
                receive_buffer,
                receive_buffer + receive_length);
    }

    return true;
}

static flutter::EncodableMap TestApdu() {

    flutter::EncodableMap response;

    bool success = false;

    response[flutter::EncodableValue("success")] =
            flutter::EncodableValue(success);

    SCARDCONTEXT context = 0;

    LONG status = SCardEstablishContext(
            SCARD_SCOPE_USER,
            nullptr,
            nullptr,
            &context);

    if (status != SCARD_S_SUCCESS) {
        response[flutter::EncodableValue("error")] =
                flutter::EncodableValue("SCardEstablishContext");
        return response;
    }

    DWORD readers_length = 0;

    status = SCardListReadersA(
            context,
            nullptr,
            nullptr,
            &readers_length);

    if (status != SCARD_S_SUCCESS) {
        SCardReleaseContext(context);
        response[flutter::EncodableValue("error")] =
                flutter::EncodableValue("SCardListReaders");
        return response;
    }

    std::vector<char> readers(readers_length);

    status = SCardListReadersA(
            context,
            nullptr,
            readers.data(),
            &readers_length);

    if (status != SCARD_S_SUCCESS) {
        SCardReleaseContext(context);
        response[flutter::EncodableValue("error")] =
                flutter::EncodableValue("SCardListReaders");
        return response;
    }

    SCARDHANDLE card = 0;
    DWORD protocol = 0;

    status = SCardConnectA(
            context,
            readers.data(),
            SCARD_SHARE_SHARED,
            SCARD_PROTOCOL_T0 | SCARD_PROTOCOL_T1,
            &card,
            &protocol);

    if (status != SCARD_S_SUCCESS) {
        SCardReleaseContext(context);
        response[flutter::EncodableValue("error")] =
                flutter::EncodableValue("SCardConnect");
        return response;
    }

    // Première APDU de test
    BYTE command[] = { 0x00, 0xA4, 0x00, 0x00, 0x02, 0x3F, 0x00 };


    const SCARD_IO_REQUEST* pci =
            (protocol == SCARD_PROTOCOL_T1)
            ? SCARD_PCI_T1
            : SCARD_PCI_T0;

    std::vector<BYTE> apdu_response;

    const bool transmit_success = TransmitApdu(
            card,
            pci,
            command,
            sizeof(command),
            apdu_response);

    std::ostringstream response_stream;
    response_stream
            << std::hex
            << std::uppercase
            << std::setfill('0');

    for (size_t index = 0; index < apdu_response.size(); index++) {
        if (index > 0) {
            response_stream << ' ';
        }

        response_stream
                << std::setw(2)
                << static_cast<int>(apdu_response[index]);
    }

    const std::string final_apdu_response = response_stream.str();

    response[flutter::EncodableValue("pcscStatus")] =
            flutter::EncodableValue(
                    transmit_success
                    ? static_cast<int>(SCARD_S_SUCCESS)
                    : -1);

    response[flutter::EncodableValue("responseLength")] =
            flutter::EncodableValue(
                    static_cast<int>(apdu_response.size()));

    response[flutter::EncodableValue("response")] =
            flutter::EncodableValue(final_apdu_response);

    success = transmit_success;

    response[flutter::EncodableValue("success")] =
            flutter::EncodableValue(success);

    SCardDisconnect(card, SCARD_LEAVE_CARD);
    SCardReleaseContext(context);

    return response;
}

flutter::EncodableMap CheckVitaleApiAvailability() {
    flutter::EncodableMap response;

    bool success = false;
    bool hn_init_found = false;
    bool hn_read_identity_found = false;
    bool hn_finish_found = false;

    const wchar_t* dll_path =
            L"C:\\Program Files\\santesocial\\api_lec\\api_lec64.dll";

    HMODULE module = LoadLibraryW(dll_path);

    if (module == nullptr) {
        response[flutter::EncodableValue("success")] =
                flutter::EncodableValue(success);

        response[flutter::EncodableValue("message")] =
                flutter::EncodableValue("Impossible de charger api_lec64.dll");

        response[flutter::EncodableValue("windowsError")] =
                flutter::EncodableValue(
                        static_cast<int>(GetLastError()));

        return response;
    }

    const auto hn_init = reinterpret_cast<HnInitFunction>(
            GetProcAddress(module, "Hn_Init"));

    hn_init_found = hn_init != nullptr;

    unsigned short hn_init_return = 0;
    unsigned short hn_init_mode = 0;
    unsigned short hn_init_error = 0;

    if (hn_init != nullptr) {
        const unsigned char api_path[] =
                "C:\\ProgramData\\santesocial\\api_lec64\\";

        hn_init_return = hn_init(
                api_path,
                &hn_init_mode,
                &hn_init_error);
    }

    const auto hn_read_identity =
            reinterpret_cast<HnReadVitaleIdentityFunction>(
                    GetProcAddress(
                            module,
                            "Hn_LectureVitaleDonneesIdentification"));

    hn_read_identity_found = hn_read_identity != nullptr;



    unsigned short hn_read_return = 0;
    unsigned short hn_read_error = 0;
    short hn_card_state = 0;

    std::vector<char> hn_read_buffer(64 * 1024, '\0');

    unsigned int hn_read_length =
            static_cast<unsigned int>(hn_read_buffer.size());

    if (hn_init_return == 0 && hn_read_identity != nullptr) {
        hn_read_return = hn_read_identity(
                30,
                hn_read_buffer.data(),
                &hn_read_length,
                &hn_card_state,
                &hn_read_error);

        if (hn_read_return == 0 && hn_read_length > 0) {
            const std::string xml(
                    hn_read_buffer.data(),
                    hn_read_length);

            response[flutter::EncodableValue("xml")] =
                    flutter::EncodableValue(xml);
        }
    }

    hn_finish_found =
            GetProcAddress(module, "Hn_Finir") != nullptr;

    success =
            hn_init_found &&
            hn_read_identity_found &&
            hn_finish_found;

    response[flutter::EncodableValue("success")] =
            flutter::EncodableValue(success);

    response[flutter::EncodableValue("dllLoaded")] =
            flutter::EncodableValue(true);

    response[flutter::EncodableValue("hnInitFound")] =
            flutter::EncodableValue(hn_init_found);

    response[flutter::EncodableValue("hnInitReturn")] =
            flutter::EncodableValue(
                    static_cast<int>(hn_init_return));

    response[flutter::EncodableValue("hnInitMode")] =
            flutter::EncodableValue(
                    static_cast<int>(hn_init_mode));

    response[flutter::EncodableValue("hnInitError")] =
            flutter::EncodableValue(
                    static_cast<int>(hn_init_error));

    response[flutter::EncodableValue("hnReadIdentityFound")] =
            flutter::EncodableValue(hn_read_identity_found);

    response[flutter::EncodableValue("hnReadReturn")] =
            flutter::EncodableValue(
                    static_cast<int>(hn_read_return));

    response[flutter::EncodableValue("hnReadLength")] =
            flutter::EncodableValue(
                    static_cast<int>(hn_read_length));

    response[flutter::EncodableValue("hnReadBufferSize")] =
            flutter::EncodableValue(
                    static_cast<int>(hn_read_buffer.size()));

    response[flutter::EncodableValue("hnCardState")] =
            flutter::EncodableValue(
                    static_cast<int>(hn_card_state));

    response[flutter::EncodableValue("hnReadError")] =
            flutter::EncodableValue(
                    static_cast<int>(hn_read_error));

    response[flutter::EncodableValue("hnFinishFound")] =
            flutter::EncodableValue(hn_finish_found);

    // FreeLibrary(module);

    return response;
}

bool FlutterWindow::OnCreate() {
    if (!Win32Window::OnCreate()) {
        return false;
    }

    RECT frame = GetClientArea();

    // The size here must match the window dimensions to avoid unnecessary surface
    // creation / destruction in the startup path.
    flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
            frame.right - frame.left, frame.bottom - frame.top, project_);

    // Ensure that basic setup of the controller was successful.
    if (!flutter_controller_->engine() || !flutter_controller_->view()) {
        return false;
    }

    RegisterPlugins(flutter_controller_->engine());

    smart_card_channel_ =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                    flutter_controller_->engine()->messenger(),
                            "abak.smart_card",
                            &flutter::StandardMethodCodec::GetInstance());

    smart_card_channel_->SetMethodCallHandler(
            [](const flutter::MethodCall<flutter::EncodableValue>& call,
               std::unique_ptr<
               flutter::MethodResult<flutter::EncodableValue>> result) {

                if (call.method_name() == "getStatus") {
                    result->Success(
                            flutter::EncodableValue(GetSmartCardStatus()));
                    return;
                }

                if (call.method_name() == "testApdu") {
                    result->Success(
                            flutter::EncodableValue(TestApdu()));
                    return;
                }

                if (call.method_name() == "checkVitaleApi") {
                    result->Success(
                            flutter::EncodableValue(
                                    CheckVitaleApiAvailability()));
                    return;
                }

                result->NotImplemented();
            });

    SetChildContent(flutter_controller_->view()->GetNativeWindow());

    flutter_controller_->engine()->SetNextFrameCallback([&]() {
        this->Show();
    });

    // Flutter can complete the first frame before the "show window" callback is
    // registered. The following call ensures a frame is pending to ensure the
    // window is shown. It is a no-op if the first frame hasn't completed yet.
    flutter_controller_->ForceRedraw();

    return true;
}

void FlutterWindow::OnDestroy() {
    if (flutter_controller_) {
        flutter_controller_ = nullptr;
    }

    Win32Window::OnDestroy();
}

LRESULT FlutterWindow::MessageHandler(
        HWND hwnd,
        UINT const message,
        WPARAM const wparam,
        LPARAM const lparam) noexcept {
// Give Flutter, including plugins, an opportunity to handle window messages.
if (flutter_controller_) {
std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(
                hwnd,
                message,
                wparam,
                lparam);

if (result) {
return *result;
}
}

switch (message) {
case WM_FONTCHANGE:
flutter_controller_->engine()->ReloadSystemFonts();
break;
}

return Win32Window::MessageHandler(
        hwnd,
        message,
        wparam,
        lparam);
}