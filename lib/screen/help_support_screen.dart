import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/base_state.dart';
import '../data/support_repository.dart';
import '../logic/support_cubit.dart';
import '../models/support_request.dart';

const _background = Color(0xFF17111F);
const _surface = Color(0xFF201A2B);
const _magenta = Color(0xFFE63888);
const _gold = Color(0xFFC9A15E);
const _green = Color(0xFF6BBF8C);

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key, this.repository});
  final SupportRepository? repository;

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _search = TextEditingController();
  SupportCategory? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _contactSupport() {
    Navigator.push<void>(context, MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => SupportCubit(widget.repository ?? SupportRepository()),
        child: _SupportFormScreen(initialCategory: _category),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final questions = _faqs.where((faq) =>
      (_category == null || faq.category == _category) &&
      (query.isEmpty || '${faq.question} ${faq.answer} ${faq.category.label}'
          .toLowerCase().contains(query)),
    ).toList();

    return Scaffold(
      backgroundColor: _background,
      appBar: _appBar('Help & support'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _panel(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _magenta.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.support_agent_outlined, color: _magenta, size: 28),
                  ),
                  const SizedBox(height: 18),
                  const Text('How can we help?', style: TextStyle(
                    fontSize: 27, fontWeight: FontWeight.w800, color: Colors.white,
                  )),
                  const SizedBox(height: 8),
                  const Text(
                    'Find a quick answer or send us the details of your issue.',
                    style: TextStyle(fontSize: 14, height: 1.6, color: Colors.white60),
                  ),
                ],
              )),
              const SizedBox(height: 24),
              TextField(
                key: const Key('support-faq-search'),
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: _magenta,
                decoration: _decoration('Search questions').copyWith(
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  suffixIcon: query.isEmpty ? null : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () => setState(_search.clear),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _filter('All', null),
                  ...SupportCategory.values.map((category) => _filter(category.label, category)),
                ],
              ),
              const SizedBox(height: 28),
              const Text('Frequently asked questions', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17,
              )),
              const SizedBox(height: 14),
              if (questions.isEmpty)
                _panel(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('No matching answers', style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15,
                    )),
                    const SizedBox(height: 8),
                    const Text('Try another search or contact support below.',
                      style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)),
                    TextButton(
                      onPressed: () => setState(() { _search.clear(); _category = null; }),
                      child: const Text('Show all questions', style: TextStyle(color: _gold)),
                    ),
                  ],
                ))
              else
                ...questions.map((faq) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _panel(
                    padding: EdgeInsets.zero,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        key: ValueKey(faq.question),
                        iconColor: _gold,
                        collapsedIconColor: Colors.white38,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        title: Text(faq.question, style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, height: 1.5,
                        )),
                        children: [Text(faq.answer, style: const TextStyle(
                          color: Colors.white60, fontSize: 13, height: 1.7,
                        ))],
                      ),
                    ),
                  ),
                )),
              const SizedBox(height: 18),
              _panel(child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Still need a hand?', style: TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800,
                  )),
                  const SizedBox(height: 8),
                  const Text('Send a support request. Include your pass reference if it relates to a reservation.',
                    style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.6)),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    key: const Key('contact-support'),
                    onPressed: _contactSupport,
                    style: _buttonStyle(),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Contact support'),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filter(String label, SupportCategory? value) {
    final selected = value == _category;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: _magenta.withOpacity(0.18),
      backgroundColor: _surface,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.white60,
        fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w600),
      side: BorderSide(color: selected ? _magenta.withOpacity(0.6) : Colors.white10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (_) => setState(() => _category = value),
    );
  }
}

class _SupportFormScreen extends StatefulWidget {
  const _SupportFormScreen({this.initialCategory});
  final SupportCategory? initialCategory;

  @override
  State<_SupportFormScreen> createState() => _SupportFormScreenState();
}

class _SupportFormScreenState extends State<_SupportFormScreen> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _reference = TextEditingController();
  late SupportCategory _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? SupportCategory.reservations;
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    _reference.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<SupportCubit>().submit(SupportDraft(
      category: _category,
      subject: _subject.text,
      message: _message.text,
      reservationReference: _reference.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportCubit, BaseState<String>>(
      builder: (context, state) => PopScope(
        canPop: !state.isLoading,
        child: Scaffold(
          backgroundColor: _background,
          appBar: _appBar('Contact support', busy: state.isLoading),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: state.data != null ? _receipt(state.data!) : _requestForm(state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _requestForm(BaseState<String> state) {
    return Form(
      key: _form,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Tell us what happened.', style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.w800, color: Colors.white,
          )),
          const SizedBox(height: 10),
          const Text('Your request is linked to your signed-in LISTED account. Never include an OTP, password or payment card details.',
            style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.6)),
          const SizedBox(height: 26),
          _label('What do you need help with?'),
          DropdownButtonFormField<SupportCategory>(
            value: _category,
            isExpanded: true,
            dropdownColor: _surface,
            decoration: _decoration('Select a topic'),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            iconEnabledColor: _gold,
            items: SupportCategory.values.map((category) => DropdownMenuItem(
              value: category, child: Text(category.label),
            )).toList(),
            onChanged: state.isLoading ? null : (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 20),
          _label('Subject'),
          TextFormField(
            key: const Key('support-subject'),
            controller: _subject,
            enabled: !state.isLoading,
            maxLength: 120,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _decoration('A short summary of the issue'),
            validator: SupportDraft.validateSubject,
          ),
          const SizedBox(height: 16),
          _label('Pass / reservation reference (optional)'),
          TextFormField(
            key: const Key('support-reference'),
            controller: _reference,
            enabled: !state.isLoading,
            maxLength: 100,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _decoration('Your pass code or reservation ID'),
            validator: SupportDraft.validateReference,
          ),
          const SizedBox(height: 16),
          _label('Message'),
          TextFormField(
            key: const Key('support-message'),
            controller: _message,
            enabled: !state.isLoading,
            minLines: 5,
            maxLines: 10,
            maxLength: 2000,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
            decoration: _decoration('Describe what happened and what you need help with.'),
            validator: SupportDraft.validateMessage,
          ),
          if (state.error != null) ...[
            const SizedBox(height: 10),
            Semantics(
              liveRegion: true,
              child: _panel(child: Text(state.error!, style: const TextStyle(
                color: Color(0xFFFFA6BF), fontSize: 13, height: 1.5,
              ))),
            ),
          ],
          const SizedBox(height: 22),
          ElevatedButton.icon(
            key: const Key('send-support-request'),
            onPressed: state.isLoading ? null : _submit,
            style: _buttonStyle(),
            icon: state.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_outlined, size: 18),
            label: Text(state.isLoading ? 'Sending request…' : 'Send request'),
          ),
          const SizedBox(height: 12),
          Text(state.isLoading
            ? 'Please keep this page open while your request is confirmed.'
            : 'An internet connection is required to send your request.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _receipt(String reference) {
    return _panel(child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_outline, color: _green, size: 52),
        const SizedBox(height: 22),
        const Text('Request received', textAlign: TextAlign.center, style: TextStyle(
          color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800,
        )),
        const SizedBox(height: 10),
        const Text('Your support request has been saved. Keep this reference for any follow-up.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.6)),
        const SizedBox(height: 26),
        const Text('REQUEST REFERENCE', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _gold, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        SelectableText(reference, textAlign: TextAlign.center, style: const TextStyle(
          color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700,
        )),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () async {
            try {
              await Clipboard.setData(ClipboardData(text: reference));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reference copied')));
            } catch (_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select the reference to copy it.')));
            }
          },
          icon: const Icon(Icons.copy_outlined, color: _gold, size: 17),
          label: const Text('Copy reference', style: TextStyle(color: _gold)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: _buttonStyle(),
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to help'),
        ),
      ],
    ));
  }
}

AppBar _appBar(String title, {bool busy = false}) => AppBar(
  backgroundColor: _background,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
  leading: Builder(builder: (context) => IconButton(
    tooltip: 'Back',
    onPressed: busy ? null : () => Navigator.maybePop(context),
    icon: Icon(Icons.arrow_back, color: busy ? Colors.white24 : Colors.white),
  )),
);

Widget _panel({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(20)}) => Container(
  width: double.infinity,
  padding: padding,
  decoration: BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.08)),
  ),
  child: child,
);

Widget _label(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
);

InputDecoration _decoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
  filled: true,
  fillColor: _surface,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
  errorStyle: const TextStyle(color: Color(0xFFFFA6BF), fontSize: 12),
  errorMaxLines: 3,
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _magenta)),
  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFA6BF))),
  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFA6BF))),
);

ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
  backgroundColor: _magenta,
  foregroundColor: Colors.white,
  disabledBackgroundColor: _magenta.withOpacity(0.35),
  disabledForegroundColor: Colors.white60,
  minimumSize: const Size(0, 50),
  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);

class _Faq {
  const _Faq(this.category, this.question, this.answer);
  final SupportCategory category;
  final String question;
  final String answer;
}

const _faqs = [
  _Faq(SupportCategory.reservations, 'Where can I find my pass?',
    'Open My passes from the bottom navigation or Profile. Select your reservation to view its details. Make sure you are signed in with the same mobile number used to reserve.'),
  _Faq(SupportCategory.reservations, 'Why has a pass disappeared?',
    'Passes are linked to their event. If the host deletes the event, its reservations are removed and its passes disappear. If you think a pass is missing by mistake, send a support request with the event name and your pass reference.'),
  _Faq(SupportCategory.reservations, 'How do table payments work?',
    'LISTED does not collect table payments or deposits in the app. Confirm any minimum spend, deposit, inclusions and payment arrangements directly with the venue or host before attending.'),
  _Faq(SupportCategory.reservations, 'Can I change or cancel a reservation?',
    'Self-service changes and cancellations are not available in the current app. Send a support request with your pass reference and the change you need. A request does not automatically change or cancel your reservation.'),
  _Faq(SupportCategory.account, 'How do I edit my profile?',
    'Open Profile, then Settings and Edit profile. You can update your name, age, gender and photo. Your sign-in mobile number is not changed by editing your profile.'),
  _Faq(SupportCategory.account, 'What if my OTP does not arrive?',
    'Check your mobile number, mobile signal and SMS inbox. Wait before requesting another code, and use the latest code you receive. If the issue continues, try signing in again later. Never share an OTP with anyone.'),
  _Faq(SupportCategory.venue, 'What should I carry for entry?',
    'Keep your pass ready and read the event entry notes before you leave. Carry a valid photo ID. Confirm age requirements, arrival time, dress code and other venue policies with the host or venue.'),
  _Faq(SupportCategory.venue, 'Why does a saved venue have no events?',
    'A saved venue stays bookmarked even when its events end or are removed. Its page shows available upcoming events. If there are none, check again when the host publishes another event.'),
  _Faq(SupportCategory.technical, 'Why can I not see an event on Home?',
    'Home shows upcoming events that match the selected filters. Try All and check your search text. Past or deleted events do not appear as upcoming events.'),
  _Faq(SupportCategory.technical, 'What should I do if something is not loading?',
    'Check your internet connection, reopen the screen and try again. If you still have the issue, contact support with the screen name, what you were doing and any error message. Avoid sending passwords or OTPs.'),
  _Faq(SupportCategory.other, 'How do I report an incorrect listing?',
    'Choose Contact support and include the event title, venue, date and the detail that looks incorrect. Your report does not automatically change the listing.'),
];
