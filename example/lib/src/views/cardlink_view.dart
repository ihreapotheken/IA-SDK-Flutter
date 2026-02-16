import 'dart:async';
import 'dart:convert';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:appsdk_v2_flutter_plugin_example/ia_client_config.dart';
import 'package:flutter/material.dart';

class CardLinkView extends StatefulWidget {
  const CardLinkView({super.key});

  @override
  State<CardLinkView> createState() => _CardLinkViewState();
}

class _CardLinkViewState extends State<CardLinkView> {
  final _userIdController = TextEditingController(text: 'test_user_123');
  final _cardNameController = TextEditingController(text: 'My Card');
  final _phoneNumberController = TextEditingController(text: '+491234567890');
  final _canCodeController = TextEditingController();

  IaCardLinkConsentStatus _consentStatus = IaCardLinkConsentStatus.showConsent;
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
        _buildPresetDataSection(context),
        const SizedBox(height: 24),
        _buildConsentStatusSelector(context),
        const SizedBox(height: 24),
        _buildLaunchSection(context),
        const SizedBox(height: 24),
        _buildInfoMethodsSection(context),
        const SizedBox(height: 24),
        _buildCardManagementSection(context),
        const SizedBox(height: 24),
        _buildResultSection(context),
        const SizedBox(height: 24),
        _buildEventLogSection(context),
      ],
    );
  }

  Widget _buildPresetDataSection(BuildContext context) {
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
              onPressed: _onResetPresetDataPressed,
              child: Text('Reset All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildClearableTextField(
          controller: _userIdController,
          label: 'User ID',
        ),
        const SizedBox(height: 12),
        _buildClearableTextField(
          controller: _cardNameController,
          label: 'Card Name',
        ),
        const SizedBox(height: 12),
        _buildClearableTextField(
          controller: _phoneNumberController,
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildClearableTextField(
          controller: _canCodeController,
          label: 'CAN Code (optional)',
          hint: '6-digit code from health card',
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
      ],
    );
  }

  Widget _buildClearableTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
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
            setState(() {});
          },
        ),
      ),
      keyboardType: keyboardType,
      maxLength: maxLength,
    );
  }

  void _onResetPresetDataPressed() {
    setState(() {
      _userIdController.clear();
      _cardNameController.clear();
      _phoneNumberController.clear();
      _canCodeController.clear();
    });
  }

  Widget _buildConsentStatusSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consent Status',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        RadioGroup<IaCardLinkConsentStatus>(
          groupValue: _consentStatus,
          onChanged: (value) {
            if (value != null) setState(() => _consentStatus = value);
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

  Widget _buildLaunchSection(BuildContext context) {
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
          value: _saveCardEnabled,
          onChanged: (value) => setState(() => _saveCardEnabled = value),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.nfc),
          label: Text('Launch CardLink'),
          onPressed: _onLaunchCardLinkPressed,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.credit_card),
          label: Text('Launch Saved Cards'),
          onPressed: _onLaunchSavedCardsPressed,
        ),
      ],
    );
  }

  Widget _buildInfoMethodsSection(BuildContext context) {
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
          onPressed: _onGetVersionPressed,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Environment'),
          onPressed: _onGetEnvironmentPressed,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Log File Path'),
          onPressed: _onGetLogFilePathPressed,
        ),
      ],
    );
  }

  Widget _buildCardManagementSection(BuildContext context) {
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
          onPressed: _onGetSavedCardsPressed,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Delete Card'),
          onPressed: _onDeleteCardPressed,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade700,
          ),
          child: Text('Delete All Cards'),
          onPressed: _onDeleteAllCardsPressed,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade700,
          ),
          child: Text('Delete All User Related Data'),
          onPressed: _onDeleteAllUserRelatedDataPressed,
        ),
      ],
    );
  }

  Widget _buildResultSection(BuildContext context) {
    if (_resultText.isEmpty) return const SizedBox.shrink();

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
              onPressed: () {
                setState(() {
                  _resultText = '';
                });
              },
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
            _resultText,
            style: TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Widget _buildEventLogSection(BuildContext context) {
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
            if (_eventLog.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _eventLog.clear();
                  });
                },
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
          child: _eventLog.isEmpty
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
                  itemCount: _eventLog.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: SelectableText(
                        _eventLog[index],
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

  // -- Actions --

  Future<void> _onLaunchCardLinkPressed() async {
    try {
      final canCode = _canCodeController.text.trim();
      await IaSdk.instance.cardLink.launch(
        sdkApiKey: ExampleAppConfig.instance.accessKey,
        flowType: IaCardLinkFlowType.cardLink,
        pharmacyId: '2163',
        consentStatus: _consentStatus,
        phoneNumber: _phoneNumberController.text,
        userId: _userIdController.text,
        finishAction: IaCardLinkFinishAction.uploadPrescriptions,
        cardName: _cardNameController.text,
        canCode: canCode.isNotEmpty ? canCode : null,
        saveCardEnabled: _saveCardEnabled,
        environment: IaCardLinkEnvironment.debug,
      );
      _showResult('CardLink launched');
    } catch (e) {
      _showResult('Error: $e');
    }
  }

  Future<void> _onLaunchSavedCardsPressed() async {
    try {
      final canCode = _canCodeController.text.trim();
      await IaSdk.instance.cardLink.launch(
        sdkApiKey: ExampleAppConfig.instance.accessKey,
        flowType: IaCardLinkFlowType.savedCards,
        pharmacyId: '2163',
        consentStatus: _consentStatus,
        phoneNumber: _phoneNumberController.text,
        userId: _userIdController.text,
        finishAction: IaCardLinkFinishAction.uploadPrescriptions,
        cardName: _cardNameController.text,
        canCode: canCode.isNotEmpty ? canCode : null,
        saveCardEnabled: _saveCardEnabled,
        environment: IaCardLinkEnvironment.debug,
      );
      _showResult('Saved Cards launched');
    } catch (e) {
      _showResult('Error: $e');
    }
  }

  Future<void> _onGetVersionPressed() async {
    try {
      final version = await IaSdk.instance.cardLink.getVersion();
      _showResult('Version: $version');
    } catch (e) {
      _showResult('Error: $e');
    }
  }

  Future<void> _onGetEnvironmentPressed() async {
    try {
      final environment = await IaSdk.instance.cardLink.getEnvironment();
      _showResult('Environment: $environment');
    } catch (e) {
      _showResult('Error: $e');
    }
  }

  Future<void> _onGetLogFilePathPressed() async {
    try {
      final logPath = await IaSdk.instance.cardLink.getLogFilePath();
      _showResult('Log path: $logPath');
    } catch (e) {
      _showResult('Error: $e');
    }
  }

  Future<void> _onGetSavedCardsPressed() async {
    try {
      final cardsJson = await IaSdk.instance.cardLink.getSavedCards(
        _userIdController.text,
      );
      if (cardsJson == null || cardsJson.isEmpty) {
        _showResult('No saved cards found.');
        return;
      }
      final formatted = const JsonEncoder.withIndent('  ').convert(
        jsonDecode(cardsJson),
      );
      _showResult('Saved cards:\n$formatted');
    } catch (e) {
      _showResult('Error: $e');
    }
  }

  Future<void> _onDeleteCardPressed() async {
    try {
      await IaSdk.instance.cardLink.deleteCard(
        userId: _userIdController.text,
        cardName: _cardNameController.text,
      );
      _showResult('Card "${_cardNameController.text}" deleted.');
    } catch (e) {
      _showResult('Error: $e');
    }
  }

  Future<void> _onDeleteAllCardsPressed() async {
    try {
      final status = await IaSdk.instance.cardLink.deleteAllCards();
      _showResult('Delete all cards: $status');
    } catch (e) {
      _showResult('Error: $e');
    }
  }

  Future<void> _onDeleteAllUserRelatedDataPressed() async {
    try {
      await IaSdk.instance.cardLink.deleteAllUserRelatedData();
      _showResult('All user related data deleted.');
    } catch (e) {
      _showResult('Error: $e');
    }
  }
}
