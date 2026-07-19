#include "vitale_api.h"

#include <windows.h>

#include <string>
#include <vector>

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

flutter::EncodableMap ReadVitaleXml() {
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
                flutter::EncodableValue(
                        "Impossible de charger api_lec64.dll");

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

    // Conservé comme dans l’implémentation validée.
    // FreeLibrary(module);

    return response;
}