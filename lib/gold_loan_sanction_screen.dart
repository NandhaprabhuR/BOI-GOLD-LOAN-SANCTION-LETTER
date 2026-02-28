import 'package:flutter/material.dart';
import 'pdf_service.dart';

class GoldLoanSanctionScreen extends StatefulWidget {
  const GoldLoanSanctionScreen({super.key});

  @override
  State<GoldLoanSanctionScreen> createState() => _GoldLoanSanctionScreenState();
}

class _GoldLoanSanctionScreenState extends State<GoldLoanSanctionScreen> {
  final Map<String, TextEditingController> _controllers = {
    'Branch Name': TextEditingController(),
    'Name of Borrower': TextEditingController(),
    'Loan Account Number': TextEditingController(),
    'Purpose': TextEditingController(),
    'Sanction Date': TextEditingController(),
    'Loan Term in months': TextEditingController(),
    'Sanctioned Loan Amount': TextEditingController(),
    'Rate of Interest': TextEditingController(),
    'Date of Maturity/Review': TextEditingController(),
    'Loan repayable months': TextEditingController(),
    'Number of EMIs': TextEditingController(),
    'EMI Amt': TextEditingController(),
    'Commencement of repayment': TextEditingController(),
    'Lumpsum Amt': TextEditingController(),
    'Processing Charges': TextEditingController(),
    'Gold Appraiser Charges': TextEditingController(),
    'Safe Keeping Charges': TextEditingController(),
    'Notices Charges': TextEditingController(),
    'Land Record Charges': TextEditingController(),
    'Crop image Charges': TextEditingController(),
    'Stamping Charges': TextEditingController(),
    'Penal Charges': TextEditingController(),
  };

  final List<Map<String, TextEditingController>> _goldRows = List.generate(
    3,
    (index) => {
      'Sr. No': TextEditingController(text: '${index + 1}'),
      'Description': TextEditingController(),
      'Gross Weight': TextEditingController(),
      'Deductions': TextEditingController(),
      'Net Weight': TextEditingController(),
      'Fineness': TextEditingController(),
      'Valuation Rate': TextEditingController(),
      'Total Value': TextEditingController(),
      'Condition': TextEditingController(),
    },
  );

  bool _isGeneratingPdf = false;

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var row in _goldRows) {
      for (var controller in row.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Map<String, dynamic> _getFormData() {
    return {
      'main': _controllers.map((key, controller) => MapEntry(key, controller.text)),
      'gold': _goldRows.map((row) => row.map((key, controller) => MapEntry(key, controller.text))).toList(),
    };
  }

  Future<void> _handlePdfGeneration() async {
    setState(() => _isGeneratingPdf = true);
    try {
      await PdfService.generateGoldLoanPdf(_getFormData());
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Gold Loan Sanction Letter'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        actions: [
          if (_isGeneratingPdf)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _handlePdfGeneration,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Table(
              border: TableBorder.all(color: Colors.black, width: 0.5),
              columnWidths: const {
                0: FlexColumnWidth(1.0),
                1: FlexColumnWidth(3.0),
              },
              children: [
                _buildFormRow('Branch Name'),
                _buildFormRow('Name of Borrower'),
                _buildFormRow('Loan Account Number'),
                _buildFormRow('Purpose'),
                _buildFormRow('Sanction Date'),
                _buildFormRow('Loan Term in months'),
                _buildFormRow('Sanctioned Loan Amount'),
                _buildInterestRow(),
                _buildFormRow('Date of Maturity/Review'),
                _buildRepaymentRow(),
                _buildFormRow('Processing Charges'),
                _buildFormRow('Gold Appraiser Charges'),
                _buildSafeKeepingRow(),
                _buildFormRow('Charges related to issuing of notices for repayment, recovery or auction etc.', key: 'Notices Charges'),
                _buildFormRow('Charges of verification of land record', key: 'Land Record Charges'),
                _buildFormRow('Charges of verification of capturing crop image/Farm record', key: 'Crop image Charges'),
                _buildFormRow('Stamping/e-stamping/e-signing charges for execution of documents/ Digital lending charges', key: 'Stamping Charges'),
                _buildFormRow('Penal charges, if any, in case of delayed payment', key: 'Penal Charges'),
                _buildGoldDetailsRow(),
                _buildTermsAndConditionsRow(),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ... (previous widgets remain same until _buildGoldDetailsRow)

  TableRow _buildGoldDetailsRow() {
    return TableRow(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Details of pledged Gold Ornaments/Coins', style: TextStyle(fontSize: 14)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const FixedColumnWidth(80),
            border: TableBorder.all(color: Colors.black, width: 0.5),
            children: [
              TableRow(
                children: [
                  _buildSubHeader('Sr. No'),
                  _buildSubHeader('Description of gold jewellery'),
                  _buildSubHeader('Gross Weight (in gram)'),
                  _buildSubHeader('Deductions (if any)'),
                  _buildSubHeader('Net Weight (in gram)'),
                  _buildSubHeader('Fineness/ Purity'),
                  _buildSubHeader('Valuation Rate per gram (Rs)'),
                  _buildSubHeader('Total Current Value (Rs)'),
                  _buildSubHeader('Condition of the jewelry'),
                ],
              ),
              ..._goldRows.map((row) => TableRow(
                    children: [
                      _buildInlineField(row['Sr. No']!),
                      _buildInlineField(row['Description']!),
                      _buildInlineField(row['Gross Weight']!),
                      _buildInlineField(row['Deductions']!),
                      _buildInlineField(row['Net Weight']!),
                      _buildInlineField(row['Fineness']!),
                      _buildInlineField(row['Valuation Rate']!),
                      _buildInlineField(row['Total Value']!),
                      _buildInlineField(row['Condition']!),
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildTermsAndConditionsRow() {
    final terms = [
      'The loan shall be repayable on demand and shall be secured by the pledge of gold jewellery/ornaments/coins acceptable to the Bank.',
      'The Bank may, at its sole discretion and upon written request from the Borrower, permit repayment in instalments/interest/lumpsum payment. Such permission shall be without prejudice to the Bank\'s right to recall the entire outstanding dues at any time.',
      'The pledged gold jewellery/ornaments/coins shall be valued by an appraiser appointed by the Bank, in accordance with applicable regulatory guidelines. The cost of valuation shall be borne by the Borrower.',
      'The Borrower acknowledges and consents that the pledged gold may be periodically inspected, re-appraised, or revalued by the Bank, including by its internal/external auditors or appraisers, as required under regulatory or Bank guidelines.',
      'The Borrower irrevocably authorizes the Bank to open sealed packets containing the pledged gold ornaments/articles in the absence of the Borrower, for inspection or revaluation purposes, without further notice. The revised value determined by the Bank\'s authorized valuer shall be final and binding.',
      'The Borrower shall maintain the prescribed LTV ratio throughout the tenure of the loan, as stipulated by the Bank in line with RBI guidelines.',
    ];

    return TableRow(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Other Terms and Condition', style: TextStyle(fontSize: 14)),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: terms
                .map((term) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(term, style: const TextStyle(fontSize: 11))),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInlineField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('ANNEXURE-IVB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance, color: Color(0xFF003366), size: 40),
              const SizedBox(width: 10),
              Column(
                children: const [
                  Text('बैंक ऑफ़ इंडिया', style: TextStyle(fontSize: 14)),
                  Text('Bank of India', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF003366))),
                ],
              ),
              const SizedBox(width: 10),
              const Icon(Icons.star_outline, color: Colors.orange, size: 30),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'GOLD LOAN SANCTION LETTER',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  TableRow _buildFormRow(String label, {String? key}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: _controllers[key ?? label],
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  TableRow _buildInterestRow() {
    return TableRow(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Rate of Interest', style: TextStyle(fontSize: 14)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  const Text('RBLR/MCLR= '),
                  Expanded(
                    child: TextField(
                      controller: _controllers['Rate of Interest'],
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: '--------'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Text('%'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Any subsequent changes will be applicable accordingly.', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  TableRow _buildRepaymentRow() {
    return TableRow(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Repayment Terms', style: TextStyle(fontSize: 14)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('Loan is repayable within '),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _controllers['Loan repayable months'],
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: '..........'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Expanded(child: Text('months from the date of sanction and the repayment schedule is as under:')),
                ],
              ),
            ),
            Table(
              border: TableBorder.all(color: Colors.black, width: 0.5),
              children: [
                TableRow(
                  children: [
                    _buildSubHeader('EMI'),
                    _buildSubHeader('Number of EMIs'),
                    _buildSubHeader('EMI Amt'),
                    _buildSubHeader('Rs.'),
                    _buildSubHeader('Commencement of repayment,'),
                  ],
                ),
                TableRow(
                  children: [
                    const SizedBox(),
                    _buildSubField('Number of EMIs'),
                    const SizedBox(),
                    _buildSubField('EMI Amt'),
                    _buildSubField('Commencement of repayment'),
                  ],
                ),
                TableRow(
                  children: [
                    _buildSubHeader('Overdraft'),
                    const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(padding: EdgeInsets.all(4.0)),
                    ),
                    _buildSubHeader('As and when demand', span: 3),
                    const SizedBox(),
                    const SizedBox(),
                  ],
                ),
                TableRow(
                  children: [
                    _buildSubHeader('Bullet Repayment'),
                    _buildSubHeader('Lumpsum Amt'),
                    _buildSubHeader('Rs.'),
                    _buildSubField('Lumpsum Amt', span: 2),
                    const SizedBox(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  TableRow _buildSafeKeepingRow() {
    return TableRow(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Safe Keeping Charges:', style: TextStyle(fontSize: 14)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Applicable Charges:', style: TextStyle(fontSize: 14)),
            ),
            Table(
              border: TableBorder.all(color: Colors.black, width: 0.5),
              children: [
                TableRow(
                  children: [
                    _buildSubHeader('Loan Amount'),
                    _buildSubHeader('Safe-keeping Charges'),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(padding: EdgeInsets.all(4.0), child: Text('Up to Rs. 25000')),
                    const Padding(padding: EdgeInsets.all(4.0), child: Text('Nil')),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(padding: EdgeInsets.all(4.0), child: Text('Above 25000 to Rs.5.00 Lakh')),
                    const Padding(padding: EdgeInsets.all(4.0), child: Text('Rs.150.00 per month or part thereof')),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(padding: EdgeInsets.all(4.0), child: Text('Above Rs.5.00 Lakh')),
                    const Padding(padding: EdgeInsets.all(4.0), child: Text('Rs.300.00 per month or part thereof')),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Note: Safe Keeping Charge will be applicable after 30 days of the expiry of the prescribed tenureof gold loan or after 30 days of closure of loan if jewels are not redeemed.',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubHeader(String text, {int span = 1}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSubField(String key, {int span = 1}) {
    return TextField(
      controller: _controllers[key],
      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}
