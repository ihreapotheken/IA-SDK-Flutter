import 'dart:async';
import 'dart:convert';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';

class CardLinkView extends StatefulWidget {
  const CardLinkView({super.key});

  @override
  State<CardLinkView> createState() => _CardLinkViewState();
}

class _CardLinkViewState extends State<CardLinkView> {
  static const _sdkApiKey =
      'fa0e9523f1a8b20c2038dc65241af81a3882f6f6a73d987fa2ae92e48e740d36';

  final _userIdController = TextEditingController(text: 'test_user_123');
  final _cardNameController = TextEditingController(text: 'My Card');
  final _phoneNumberController = TextEditingController(text: '+491234567890');
  final _canCodeController = TextEditingController();

  IaCardLinkConsentStatus _consentStatus =
      IaCardLinkConsentStatus.showConsent;
  bool _saveCardEnabled = false;
  String _resultText = '';
  final List<String> _eventLog = [];

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _setupStreamListeners();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _userIdController.dispose();
    _cardNameController.dispose();
    _phoneNumberController.dispose();
    _canCodeController.dispose();
    super.dispose();
  }

  void _setupStreamListeners() {
    final cardLink = IaSdk.instance.cardLink;

    _subscriptions.add(
      cardLink.consentEventListener.stream.listen((event) {
        _addEventLog('Consent: ${event.name}');
      }),
    );

    _subscriptions.add(
      cardLink.sessionCreatedListener.stream.listen((session) {
        _addEventLog('Session created: ${session.data}');
      }),
    );

    _subscriptions.add(
      cardLink.prescriptionsRedeemedListener.stream.listen((prescriptions) {
        _addEventLog('Prescriptions redeemed: $prescriptions');
      }),
    );

    _subscriptions.add(
      cardLink.eventListener.stream.listen((event) {
        _addEventLog('Event: ${event.name}');
      }),
    );

    _subscriptions.add(
      cardLink.analyticsEventListener.stream.listen((event) {
        _addEventLog('Analytics: $event');
      }),
    );
  }

  void _addEventLog(String entry) {
    setState(() {
      final timestamp = TimeOfDay.now().format(context);
      _eventLog.insert(0, '[$timestamp] $entry');
    });
  }

  void _showResult(String result) {
    setState(() {
      _resultText = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        24 + MediaQuery.of(context).padding.top,
        20,
        24,
      ),
      children: [
        Text(
          'CardLink Services',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _PresetDataSection(
          userIdController: _userIdController,
          cardNameController: _cardNameController,
          phoneNumberController: _phoneNumberController,
          canCodeController: _canCodeController,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 24),
        _ConsentStatusSection(
          value: _consentStatus,
          onChanged: (value) => setState(() => _consentStatus = value),
        ),
        const SizedBox(height: 24),
        _LaunchSection(
          saveCardEnabled: _saveCardEnabled,
          onSaveCardEnabledChanged: (value) =>
              setState(() => _saveCardEnabled = value),
          onLaunchCardLink: () async {
            try {
              final canCode = _canCodeController.text.trim();
              await IaSdk.instance.cardLink.launch(
                sdkApiKey: _sdkApiKey,
                flowType: IaCardLinkFlowType.cardLink,
                pharmacyId: '2163',
                consentStatus: _consentStatus,
                phoneNumber: _phoneNumberController.text,
                userId: _userIdController.text,
                cardName: _cardNameController.text,
                canCode: canCode.isNotEmpty ? canCode : null,
                saveCardEnabled: _saveCardEnabled,
                environment: IaCardLinkEnvironment.debug,
              );
              _showResult('CardLink launched');
            } catch (e) {
              _showResult('Error: $e');
            }
          },
          onLaunchSavedCards: () async {
            try {
              final canCode = _canCodeController.text.trim();
              await IaSdk.instance.cardLink.launch(
                sdkApiKey: _sdkApiKey,
                flowType: IaCardLinkFlowType.savedCards,
                pharmacyId: '2163',
                consentStatus: _consentStatus,
                phoneNumber: _phoneNumberController.text,
                userId: _userIdController.text,
                cardName: _cardNameController.text,
                canCode: canCode.isNotEmpty ? canCode : null,
                saveCardEnabled: _saveCardEnabled,
                environment: IaCardLinkEnvironment.debug,
              );
              _showResult('Saved Cards launched');
            } catch (e) {
              _showResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 24),
        _InfoMethodsSection(
          onShowResult: _showResult,
        ),
        const SizedBox(height: 24),
        _CardManagementSection(
          userIdController: _userIdController,
          cardNameController: _cardNameController,
          onShowResult: _showResult,
        ),
        const SizedBox(height: 24),
        if (_resultText.isNotEmpty) ...[
          _ResultSection(
            text: _resultText,
            onClear: () => setState(() => _resultText = ''),
          ),
          const SizedBox(height: 24),
        ],
        _EventLogSection(
          eventLog: _eventLog,
          onClear: () => setState(() => _eventLog.clear()),
        ),
      ],
    );
  }
}

class _PresetDataSection extends StatelessWidget {
  const _PresetDataSection({
    required this.userIdController,
    required this.cardNameController,
    required this.phoneNumberController,
    required this.canCodeController,
    required this.onChanged,
  });

  final TextEditingController userIdController;
  final TextEditingController cardNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController canCodeController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Preset Data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () {
                userIdController.clear();
                cardNameController.clear();
                phoneNumberController.clear();
                canCodeController.clear();
                onChanged();
              },
              child: Text('Reset All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ClearableTextField(
          controller: userIdController,
          label: 'User ID',
          onCleared: onChanged,
        ),
        const SizedBox(height: 12),
        _ClearableTextField(
          controller: cardNameController,
          label: 'Card Name',
          onCleared: onChanged,
        ),
        const SizedBox(height: 12),
        _ClearableTextField(
          controller: phoneNumberController,
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
          onCleared: onChanged,
        ),
        const SizedBox(height: 12),
        _ClearableTextField(
          controller: canCodeController,
          label: 'CAN Code (optional)',
          hint: '6-digit code from health card',
          keyboardType: TextInputType.number,
          maxLength: 6,
          onCleared: onChanged,
        ),
      ],
    );
  }
}

class _ClearableTextField extends StatelessWidget {
  const _ClearableTextField({
    required this.controller,
    required this.label,
    required this.onCleared,
    this.hint,
    this.keyboardType,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear, size: 18),
          onPressed: () {
            controller.clear();
            onCleared();
          },
        ),
      ),
      keyboardType: keyboardType,
      maxLength: maxLength,
    );
  }
}

class _ConsentStatusSection extends StatelessWidget {
  const _ConsentStatusSection({
    required this.value,
    required this.onChanged,
  });

  final IaCardLinkConsentStatus value;
  final ValueChanged<IaCardLinkConsentStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consent Status',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        RadioGroup<IaCardLinkConsentStatus>(
          groupValue: value,
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
          child: Column(
            children: [
              RadioListTile<IaCardLinkConsentStatus>(
                title: Text('Show Consent'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: IaCardLinkConsentStatus.showConsent,
              ),
              RadioListTile<IaCardLinkConsentStatus>(
                title: Text('Consent Accepted'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: IaCardLinkConsentStatus.consentAccepted,
              ),
              RadioListTile<IaCardLinkConsentStatus>(
                title: Text('Consent Declined'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: IaCardLinkConsentStatus.consentDeclined,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LaunchSection extends StatelessWidget {
  const _LaunchSection({
    required this.saveCardEnabled,
    required this.onSaveCardEnabledChanged,
    required this.onLaunchCardLink,
    required this.onLaunchSavedCards,
  });

  final bool saveCardEnabled;
  final ValueChanged<bool> onSaveCardEnabledChanged;
  final VoidCallback onLaunchCardLink;
  final VoidCallback onLaunchSavedCards;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Launch',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SwitchListTile(
          title: Text('Save Card Enabled'),
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: saveCardEnabled,
          onChanged: onSaveCardEnabledChanged,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.nfc),
          label: Text('Launch CardLink'),
          onPressed: onLaunchCardLink,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.credit_card),
          label: Text('Launch Saved Cards'),
          onPressed: onLaunchSavedCards,
        ),
      ],
    );
  }
}

class _InfoMethodsSection extends StatelessWidget {
  const _InfoMethodsSection({
    required this.onShowResult,
  });

  final ValueChanged<String> onShowResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Info Methods',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Version'),
          onPressed: () async {
            try {
              final version = await IaSdk.instance.cardLink.getVersion();
              onShowResult('Version: $version');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Environment'),
          onPressed: () async {
            try {
              final environment =
                  await IaSdk.instance.cardLink.getEnvironment();
              onShowResult('Environment: $environment');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Log File Path'),
          onPressed: () async {
            try {
              final logPath = await IaSdk.instance.cardLink.getLogFilePath();
              onShowResult('Log path: $logPath');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
      ],
    );
  }
}

class _CardManagementSection extends StatelessWidget {
  const _CardManagementSection({
    required this.userIdController,
    required this.cardNameController,
    required this.onShowResult,
  });

  final TextEditingController userIdController;
  final TextEditingController cardNameController;
  final ValueChanged<String> onShowResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Management',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Saved Cards'),
          onPressed: () async {
            try {
              final cardsJson = await IaSdk.instance.cardLink.getSavedCards(
                userIdController.text,
              );
              if (cardsJson == null || cardsJson.isEmpty) {
                onShowResult('No saved cards found.');
                return;
              }
              final formatted = const JsonEncoder.withIndent('  ').convert(
                jsonDecode(cardsJson),
              );
              onShowResult('Saved cards:\n$formatted');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Delete Card'),
          onPressed: () async {
            try {
              await IaSdk.instance.cardLink.deleteCard(
                userId: userIdController.text,
                cardName: cardNameController.text,
              );
              onShowResult('Card "${cardNameController.text}" deleted.');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade700,
          ),
          child: Text('Delete All Cards'),
          onPressed: () async {
            try {
              final status = await IaSdk.instance.cardLink.deleteAllCards();
              onShowResult('Delete all cards: $status');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade700,
          ),
          child: Text('Delete All User Related Data'),
          onPressed: () async {
            try {
              await IaSdk.instance.cardLink.deleteAllUserRelatedData();
              onShowResult('All user related data deleted.');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.text,
    required this.onClear,
  });

  final String text;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Result',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: onClear,
              child: Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            text,
            style: TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}

class _EventLogSection extends StatelessWidget {
  const _EventLogSection({
    required this.eventLog,
    required this.onClear,
  });

  final List<String> eventLog;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Event Log',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (eventLog.isNotEmpty)
              TextButton(
                onPressed: onClear,
                child: Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: eventLog.isEmpty
              ? Center(
                  child: Text(
                    'No events yet.\nLaunch CardLink to see live events.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: eventLog.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: SelectableText(
                        eventLog[index],
                        style: TextStyle(
                          color: Colors.green.shade300,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
