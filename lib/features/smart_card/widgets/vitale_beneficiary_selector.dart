import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:abak_vitale/abak_vitale.dart';
import '../../../generated/l10n.dart';

class VitaleBeneficiarySelector {
  static Future<VitaleIdentity?> show(
      BuildContext context,
      List<VitaleIdentity> identities,
      ) {
    final s = S.of(context);
    final dateFormat = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return showDialog<VitaleIdentity>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(s.vitaleBeneficiarySelector_selectBeneficiary),
          content: SizedBox(
            width: 520,
            height: 420,
            child: ListView.separated(
              itemCount: identities.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final identity = identities[index];

                final birthDate = identity.birthDate == null
                    ? ''
                    : dateFormat.format(identity.birthDate!);

                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    '${identity.lastName ?? ''} ${identity.firstName ?? ''}',
                  ),
                  subtitle: Text(birthDate),
                  onTap: () {
                    Navigator.of(context).pop(identity);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.vitaleBeneficiarySelector_cancel),
            ),
          ],
        );
      },
    );
  }
}