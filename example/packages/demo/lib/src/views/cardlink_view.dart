import 'dart:async';
import 'dart:convert';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';
import 'package:ia_example_demo/ia_client_config.dart';
import 'package:ia_example_demo/src/file_utils.dart';
import 'package:ia_example_shared/ia_example_shared.dart';

class CardLinkViewStateData {
  final userIdController = TextEditingController(text: ExampleAppConfig.cardLinkUserId);
  final cardNameController = TextEditingController();
  final phoneNumberController = TextEditingController(text: '+491234567890');
  final canCodeController = TextEditingController();

  IaCardLinkConsentStatus consentStatus = IaCardLinkConsentStatus.showConsent;
  bool saveCardEnabled = false;
  bool includeCoreAppLogs = false;
  bool usesCustomColors = false;
  bool isInvalidXmlDataMocked = false;
  IaCardLinkIllustrationColor illustrationColor = IaCardLinkIllustrationColor.red;

  String resultText = '';
  final List<String> eventLog = [];

  void resetControllers() {
    userIdController.clear();
    cardNameController.clear();
    phoneNumberController.clear();
    canCodeController.clear();
  }

  void dispose() {
    userIdController.dispose();
    cardNameController.dispose();
    phoneNumberController.dispose();
    canCodeController.dispose();
  }
}

/// The CardLink module: launching its flows with preset data, its info methods and saved card management, and a log
/// of its events.
///
class CardLinkView extends StatefulWidget {
  const CardLinkView({super.key});

  @override
  State<CardLinkView> createState() => _CardLinkViewState();
}

class _CardLinkViewState extends State<CardLinkView> {
  static const _customColor = 0xFF2E7D32;

  final _data = CardLinkViewStateData();
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _setupStreamListeners();
  }

  void _setupStreamListeners() {
    final cardLink = IaSdk.instance.cardLink;
    _subscriptions.addAll([
      cardLink.consentEventListener.stream.listen((event) => _addEventLog('Consent: ${event.name}')),
      cardLink.sessionCreatedListener.stream.listen((session) => _addEventLog('Session created: ${session.data}')),
      cardLink.prescriptionsRedeemedListener.stream.listen((prescriptions) => _addEventLog('Prescriptions redeemed: $prescriptions')),
      cardLink.eventListener.stream.listen((event) => _addEventLog('Event: ${event.name}')),
      cardLink.analyticsEventListener.stream.listen((event) => _addEventLog('Analytics: $event')),
      cardLink.consentPhoneNumberListener.stream.listen((phoneNumber) => _addEventLog('Consent phone number: $phoneNumber')),
      cardLink.savedCardsListener.stream.listen(
        (cards) => _addEventLog('Saved cards: ${cards.map((card) => '${card.name} (CAN ${card.canCode})').join(', ')}'),
      ),
      cardLink.initializationErrorListener.stream.listen((message) => _addEventLog('Failed to initialize: ${message ?? 'no description'}')),
      cardLink.resultListener.stream.listen((result) => _addEventLog('Result: $result')),
    ]);
  }

  void _addEventLog(String entry) {
    setState(() {
      final timestamp = TimeOfDay.now().format(context);
      _data.eventLog.insert(0, '[$timestamp] $entry');
    });
  }

  /// Runs [call] and shows the result it returns, or its error, in the Result section.
  ///
  Future<void> _run(Future<String> Function() call) async {
    String result;
    try {
      result = await call();
    } catch (e) {
      result = 'Error: $e';
    }
    if (mounted) setState(() => _data.resultText = result);
  }

  String get _userId => _data.userIdController.text;

  String get _cardName => _data.cardNameController.text;

  Future<void> _launch(IaCardLinkFlowType flowType) async {
    final canCode = _data.canCodeController.text.trim();
    final cardName = _data.cardNameController.text.trim();
    await IaSdk.instance.cardLink.launch(
      sdkApiKey: ExampleAppConfig.instance.accessKey,
      flowType: flowType,
      pharmacyId: '2163',
      consentStatus: _data.consentStatus,
      phoneNumber: _data.phoneNumberController.text,
      userId: _data.userIdController.text,
      cardName: cardName.isNotEmpty ? cardName : null,
      canCode: canCode.isNotEmpty ? canCode : null,
      saveCardEnabled: _data.saveCardEnabled,
      environment: null,
      finishAction: IaCardLinkFinishAction.uploadPrescriptions,
      coreAppLogFileURL: _data.includeCoreAppLogs ? await FileUtils.createDemoCoreAppLogFile() : null,
      supportsLiquidGlass: true,
      illustrationColor: _data.illustrationColor,
      primaryColor: _data.usesCustomColors ? _customColor : null,
      buttonsColor: _data.usesCustomColors ? _customColor : null,
      textLinkColor: _data.usesCustomColors ? _customColor : null,
      bottomNavigationColor: _data.usesCustomColors ? _customColor : null,
      isInvalidXmlDataMocked: _data.isInvalidXmlDataMocked,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardLink = IaSdk.instance.cardLink;
    return IaTabListView(
      children: [
        IaNotice('CardLink runs against ${ExampleAppConfig.instance.serverEnvironment.name}, with pharmacy 2163.'),
        _PresetDataSection(
          data: _data,
          onChanged: () => setState(() {}),
        ),
        IaSection(
          title: 'Configuration',
          children: [
            IaChoiceRow(
              title: 'Consent status',
              options: const [
                (value: IaCardLinkConsentStatus.showConsent, label: 'Show Consent'),
                (value: IaCardLinkConsentStatus.consentAccepted, label: 'Accepted'),
                (value: IaCardLinkConsentStatus.consentDeclined, label: 'Declined'),
              ],
              selected: _data.consentStatus,
              onSelected: (value) => setState(() => _data.consentStatus = value),
            ),
            IaChoiceRow(
              title: 'Illustration color',
              platform: IaPlatform.android,
              options: [for (final color in IaCardLinkIllustrationColor.values) (value: color, label: color.name)],
              selected: _data.illustrationColor,
              onSelected: (color) => setState(() => _data.illustrationColor = color),
            ),
            IaSwitchRow(
              title: 'Save card enabled',
              value: _data.saveCardEnabled,
              onChanged: (value) => setState(() => _data.saveCardEnabled = value),
            ),
            IaSwitchRow(
              title: 'Include core app logs',
              description: 'Attached to problem reports',
              value: _data.includeCoreAppLogs,
              onChanged: (value) => setState(() => _data.includeCoreAppLogs = value),
            ),
            IaSwitchRow(
              title: 'Custom colors',
              description: 'Green primary, button, link and navigation colors',
              value: _data.usesCustomColors,
              onChanged: (value) => setState(() => _data.usesCustomColors = value),
            ),
            IaSwitchRow(
              title: 'Mock invalid XML data',
              description: 'Only with a debug build of the Android CardLink module',
              platform: IaPlatform.android,
              value: _data.isInvalidXmlDataMocked,
              onChanged: (value) => setState(() => _data.isInvalidXmlDataMocked = value),
            ),
          ],
        ),
        IaSection(
          title: 'Launch',
          children: [
            IaActionRow(
              title: 'Launch CardLink',
              description: 'Reads the health card and redeems its e-prescriptions',
              onTap: () => _run(() async {
                await _launch(IaCardLinkFlowType.cardLink);
                return 'CardLink launched';
              }),
            ),
            IaActionRow(
              title: 'Launch Saved Cards',
              onTap: () => _run(() async {
                await _launch(IaCardLinkFlowType.savedCards);
                return 'Saved Cards launched';
              }),
            ),
          ],
        ),
        IaSection(
          title: 'Info methods',
          children: [
            IaActionRow(title: 'Get Version', onTap: () => _run(() async => 'Version: ${await cardLink.getVersion()}')),
            IaActionRow(title: 'Get Environment', onTap: () => _run(() async => 'Environment: ${await cardLink.getEnvironment()}')),
            IaActionRow(title: 'Get Log File Path', onTap: () => _run(() async => 'Log path: ${await cardLink.getLogFilePath()}')),
            IaActionRow(
              title: 'Finish CardLink',
              platform: IaPlatform.ios,
              onTap: () => _run(() async {
                await cardLink.finish();
                return 'CardLink finished';
              }),
            ),
          ],
        ),
        IaSection(
          title: 'Card management',
          children: [
            IaActionRow(
              title: 'Get Saved Cards',
              description: 'As JSON',
              onTap: () => _run(() async {
                final cardsJson = await cardLink.getSavedCards(_userId);
                if (cardsJson == null || cardsJson.isEmpty) return 'No saved cards found.';
                return 'Saved cards:\n${const JsonEncoder.withIndent('  ').convert(jsonDecode(cardsJson))}';
              }),
            ),
            IaActionRow(
              title: 'Get Saved Card List',
              onTap: () => _run(() async {
                final cards = await cardLink.getSavedCardList(_userId);
                return cards.isEmpty
                    ? 'No saved cards found.'
                    : cards.map((card) => '${card.name}: CAN ${card.canCode}, phone ${card.phoneNumber}, id ${card.id}').join('\n');
              }),
            ),
            IaActionRow(
              title: 'Rename Saved Card',
              description: 'The card named in the preset data',
              platform: IaPlatform.android,
              onTap: () => _run(() async {
                final cards = await cardLink.getSavedCardList(_userId);
                final card = cards.where((card) => card.name == _cardName).firstOrNull;
                if (card == null) return 'No saved card named "$_cardName".';
                final newName = '${card.name} (renamed)';
                await cardLink.updateCard(
                  userId: _userId,
                  originalName: card.name,
                  name: newName,
                  phoneNumber: card.phoneNumber ?? '',
                  canCode: card.canCode ?? '',
                );
                return 'Renamed "${card.name}" to "$newName".';
              }),
            ),
            IaActionRow(
              title: 'Attach Host Log File to Problem Reports',
              onTap: () => _run(() async {
                final path = await FileUtils.createDemoCoreAppLogFile();
                await cardLink.setHostAppLogFilePath(path);
                return 'Host log file attached: $path';
              }),
            ),
            IaActionRow(
              title: 'Delete Card',
              description: 'The card named in the preset data',
              onTap: () => _run(() async {
                await cardLink.deleteCard(userId: _userId, cardName: _cardName);
                return 'Card "$_cardName" deleted.';
              }),
            ),
            IaActionRow(
              title: 'Mock CardLink Backend',
              platform: IaPlatform.ios,
              onTap: () => _run(() async {
                await cardLink.setMocks(const IaCardLinkMocks());
                return 'CardLink backend mocks enabled.';
              }),
            ),
            IaActionRow(
              title: 'Reverse Saved Cards Order',
              platform: IaPlatform.android,
              onTap: () => _run(() async {
                final cards = await cardLink.getSavedCardList(_userId);
                await cardLink.reorderSavedCards(
                  userId: _userId,
                  orderedCanCodes: cards.reversed.map((card) => card.canCode).whereType<String>().toList(),
                );
                return 'Reversed the order of ${cards.length} saved card(s).';
              }),
            ),
            IaActionRow(
              title: 'Delete All Cards',
              isDestructive: true,
              onTap: () => _run(() async => 'Delete all cards: ${await cardLink.deleteAllCards()}'),
            ),
            IaActionRow(
              title: 'Delete All User Related Data',
              isDestructive: true,
              onTap: () => _run(() async {
                await cardLink.deleteAllUserRelatedData();
                return 'All user related data deleted.';
              }),
            ),
          ],
        ),
        if (_data.resultText.isNotEmpty)
          IaSection(
            title: 'Result',
            trailing: IaLinkButton(title: 'Clear', onTap: () => setState(() => _data.resultText = '')),
            children: [
              IaBlock(
                child: SelectableText(_data.resultText, style: IaTextStyles.mono.copyWith(fontSize: 12, color: IaColors.ink)),
              ),
            ],
          ),
        IaSection(
          title: 'Event log',
          trailing: IaLinkButton(
            title: 'Clear',
            onTap: _data.eventLog.isEmpty ? null : () => setState(() => _data.eventLog.clear()),
          ),
          children: [
            IaBlock(
              child: _data.eventLog.isEmpty
                  ? Text(
                      'No events yet. Launch CardLink to see live events.',
                      style: IaTextStyles.caption.copyWith(color: IaColors.inkTertiary),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: IaSpacing.sm,
                      children: [
                        for (final entry in _data.eventLog) Text(entry, style: IaTextStyles.mono.copyWith(color: IaColors.ink)),
                      ],
                    ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _data.dispose();
    super.dispose();
  }
}

/// The user, card and phone number CardLink starts with.
///
class _PresetDataSection extends StatelessWidget {
  const _PresetDataSection({required this.data, required this.onChanged});

  final CardLinkViewStateData data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return IaSection(
      title: 'Preset data',
      trailing: IaLinkButton(
        title: 'Reset all',
        onTap: () {
          data.resetControllers();
          onChanged();
        },
      ),
      children: [
        IaBlock(
          child: Column(
            spacing: IaSpacing.md,
            children: [
              _ClearableTextField(controller: data.userIdController, label: 'User ID', onCleared: onChanged),
              _ClearableTextField(
                controller: data.cardNameController,
                label: 'Saved card name (optional)',
                hint: 'Starts CardLink with this saved card',
                onCleared: onChanged,
              ),
              _ClearableTextField(
                controller: data.phoneNumberController,
                label: 'Phone number',
                keyboardType: TextInputType.phone,
                onCleared: onChanged,
              ),
              _ClearableTextField(
                controller: data.canCodeController,
                label: 'CAN code (optional)',
                hint: '6-digit code from the health card',
                keyboardType: TextInputType.number,
                maxLength: 6,
                onCleared: onChanged,
              ),
            ],
          ),
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
    return IaTextField(
      label: label,
      controller: controller,
      hint: hint,
      keyboardType: keyboardType,
      maxLength: maxLength,
      suffix: IconButton(
        icon: const Icon(Icons.close_rounded, size: 18, color: IaColors.inkTertiary),
        tooltip: 'Clear',
        onPressed: () {
          controller.clear();
          onCleared();
        },
      ),
    );
  }
}
