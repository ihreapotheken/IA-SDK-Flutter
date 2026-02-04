import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';

class CardLinkView extends StatefulWidget {
  const CardLinkView({super.key});

  @override
  State<CardLinkView> createState() => _CardLinkViewState();
}

class _CardLinkViewState extends State<CardLinkView> {
  // Platform-specific API keys for CardLink SDK
  static const _sdkApiKey = 'fa0e9523f1a8b20c2038dc65241af81a3882f6f6a73d987fa2ae92e48e740d36';

  final _userIdController = TextEditingController(text: 'test_user_123');
  final _cardNameController = TextEditingController(text: 'My Card');
  final _phoneNumberController = TextEditingController(text: '+491234567890');
  String _resultText = '';

  @override
  void dispose() {
    _userIdController.dispose();
    _cardNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
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
        _buildInputFields(),
        const SizedBox(height: 24),
        _buildLaunchSection(context),
        const SizedBox(height: 24),
        _buildInfoMethodsSection(context),
        const SizedBox(height: 24),
        _buildCardManagementSection(context),
        const SizedBox(height: 24),
        _buildResultSection(context),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        TextField(
          controller: _userIdController,
          decoration: InputDecoration(
            labelText: 'User ID',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cardNameController,
          decoration: InputDecoration(
            labelText: 'Card Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneNumberController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
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
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.nfc),
          label: Text('Launch CardLink SDK'),
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
          child: Text('Delete Cards'),
          onPressed: _onDeleteCardPressed,
        ),
      ],
    );
  }

  Widget _buildResultSection(BuildContext context) {
    if (_resultText.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Result',
          style: Theme.of(context).textTheme.titleMedium,
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

  Future<void> _onLaunchCardLinkPressed() async {
    try {
      await IaSdk.instance.cardLink.launch(
        sdkApiKey: _sdkApiKey,
        flowType: IaCardLinkFlowType.cardLink,
        pharmacyId: '2163',
        consentStatus: IaCardLinkConsentStatus.showConsent,
        phoneNumber: _phoneNumberController.text,
        userId: _userIdController.text,
        cardName: _cardNameController.text,
        environment: IaCardLinkEnvironment.debug,
      );
      _showResult('CardLink SDK launched');
    } catch (e) {
      _showResult('Error: $e');
    }
  }

  Future<void> _onLaunchSavedCardsPressed() async {
    try {
      await IaSdk.instance.cardLink.launch(
        sdkApiKey: _sdkApiKey,
        flowType: IaCardLinkFlowType.savedCards,
        pharmacyId: '2163',
        consentStatus: IaCardLinkConsentStatus.consentAccepted,
        phoneNumber: _phoneNumberController.text,
        userId: _userIdController.text,
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
      final cards = await IaSdk.instance.cardLink.getSavedCards(
        _userIdController.text,
      );
      _showResult('Saved cards: $cards');
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
      _showResult('Card deleted successfully');
    } catch (e) {
      _showResult('Error: $e');
    }
  }
}
