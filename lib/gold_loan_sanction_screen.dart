import 'package:flutter/material.dart';

class GoldLoanSanctionScreen extends StatelessWidget {
  const GoldLoanSanctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Gold Loan Sanction Letter'),
        backgroundColor: const Color(0xFF003366), // BOI Blue
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDocumentHeader(),
              const SizedBox(height: 16),
              _buildSectionTitle('LOAN DETAILS'),
              _buildLoanDetailsCard(),
              const SizedBox(height: 16),
              _buildSectionTitle('REPAYMENT TERMS'),
              _buildRepaymentTermsCard(),
              const SizedBox(height: 16),
              _buildSectionTitle('SAFE KEEPING CHARGES'),
              _buildSafeKeepingChargesCard(),
              const SizedBox(height: 16),
              _buildSectionTitle('OTHER CHARGES & CONDITIONS'),
              _buildOtherChargesCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentHeader() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                Text(
                  'ANNEXURE-IVB',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance, color: Color(0xFF003366), size: 40),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'बैंक ऑफ़ इंडिया',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Bank of India',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF003366)),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.star_outline, color: Colors.orange, size: 30),
              ],
            ),
            const Divider(height: 32),
            const Center(
              child: Text(
                'GOLD LOAN SANCTION LETTER',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF003366),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLoanDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            _buildInfoRow('Branch Name', 'Main Branch, Mumbai'),
            _buildInfoRow('Name of Borrower', 'John Doe'),
            _buildInfoRow('Loan Account Number', '123456789012'),
            _buildInfoRow('Purpose', 'Personal/Agriculture'),
            _buildInfoRow('Sanction Date', '27/02/2026'),
            _buildInfoRow('Loan Term', '12 months'),
            _buildInfoRow('Sanctioned Amount', '₹ 2,00,000'),
            _buildInfoRow('Rate of Interest', 'RBLR/MCLR = 9.50%'),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Note: Any subsequent changes will be applicable accordingly.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ),
            _buildInfoRow('Date of Maturity/Review', '26/02/2027', isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey[200]!),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepaymentTermsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan is repayable within 12 months from the date of sanction and the repayment schedule is as under:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    _buildTableCell('Type', isHeader: true),
                    _buildTableCell('Count', isHeader: true),
                    _buildTableCell('Amount', isHeader: true),
                    _buildTableCell('Start Date', isHeader: true),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('EMI'),
                    _buildTableCell('12'),
                    _buildTableCell('₹ 17,500'),
                    _buildTableCell('05/03/2026'),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Overdraft'),
                    _buildTableCell('-', span: 3),
                    Container(),
                    Container(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Expanded(child: Text('Bullet Repayment', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Text('Lumpsum Amt: '),
                  const Text('₹ 2,00,000', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeKeepingChargesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    _buildTableCell('Loan Amount', isHeader: true),
                    _buildTableCell('Safe-keeping Charges', isHeader: true),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Up to ₹ 25,000'),
                    _buildTableCell('Nil'),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Above ₹ 25,000 to ₹ 5.00 Lakh'),
                    _buildTableCell('₹ 150.00 per month or part thereof'),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Above ₹ 5.00 Lakh'),
                    _buildTableCell('₹ 300.00 per month or part thereof'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Note: Safe Keeping Charge will be applicable after 30 days of the expiry of the prescribed tenure of gold loan or after 30 days of closure of loan if jewels are not redeemed.',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherChargesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            _buildChargeItem('Processing Charges', '₹ 500'),
            _buildChargeItem('Gold Appraiser Charges', '₹ 250'),
            _buildChargeItem('Notices for repayment/recovery/auction', 'As applicable'),
            _buildChargeItem('Verification of land record', 'As per actuals'),
            _buildChargeItem('Capturing crop image/Farm record', '₹ 100', isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildChargeItem(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, int span = 1}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
