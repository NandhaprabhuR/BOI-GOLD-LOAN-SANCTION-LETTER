import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateGoldLoanPdf(Map<String, dynamic> data) async {
    try {
      debugPrint('Starting PDF generation...');
      final pdf = pw.Document();
      final mainData = data['main'] as Map<String, String>;
      final goldData = (data['gold'] as List).cast<Map<String, String>>();

      debugPrint('Loading local fallback fonts...');
      final baseFont = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      final hindiFontData = await rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf');
      final hindiFont = pw.Font.ttf(hindiFontData);

      final hindiFontBoldData = await rootBundle.load('assets/fonts/NotoSansDevanagari-Bold.ttf');
      final hindiFontBold = pw.Font.ttf(hindiFontBoldData);
      debugPrint('Fonts loaded successfully.');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          theme: pw.ThemeData.withFont(
            base: baseFont,
            bold: boldFont,
            fontFallback: [hindiFont, hindiFontBold],
          ),
          build: (pw.Context context) {
            return [
              _buildHeader(),
              _buildSection1(mainData),
              _buildSection2(mainData),
              _buildSection3(mainData),
              _buildGoldDetailsPdfRow(goldData), 
              _buildTermsPdfRow(),
              pw.SizedBox(height: 177), // Force KFS onto a new page (Page 3)
              _buildKfsHeader(),
              _buildKfsTable(mainData),
              pw.SizedBox(height: 30), // Force APR Factsheet onto its own page (Page 4)
              _buildAprFactsheet(mainData),
              pw.SizedBox(height: 5), // Minimal gap instead of forced page break
              _buildPostSanctionReport(mainData),
            ];
          },
          footer: (pw.Context context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10.0),
            ),
          ),
        ),
      );

      debugPrint('Launching PDF layout...');
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      debugPrint('PDF layout finished.');
    } catch (e, stack) {
      debugPrint('Error generating PDF: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('ANNEXURE-IVB', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Column(
              children: [
                pw.Text('बैंक ऑफ़ इंडिया', style: pw.TextStyle(fontSize: 10.0)),
                pw.Text('Bank of India', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Center(
          child: pw.Text(
            'GOLD LOAN SANCTION LETTER',
            style: pw.TextStyle(
              fontSize: 10.0,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
        pw.SizedBox(height: 5),
      ],
    );
  }

  static pw.Widget _buildSection1(Map<String, String> data) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {0: const pw.FlexColumnWidth(0.7), 1: const pw.FlexColumnWidth(2.3)},
      children: [
        _buildDataRow('Branch Name', data['Branch Name'] ?? ''),
        _buildDataRow('Name of Borrower', data['Name of Borrower'] ?? ''),
        _buildDataRow('Loan Account Number', data['Loan Account Number'] ?? ''),
        _buildDataRow('Purpose', data['Purpose'] ?? ''),
        _buildDataRow('Sanction Date', data['Sanction Date'] ?? ''),
        _buildDataRow('Loan Term in months', data['Loan Term in months'] ?? ''),
        _buildDataRow('Sanctioned Loan Amount', data['Sanctioned Loan Amount'] ?? ''),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(1.5),
              child: pw.Text('Rate of Interest', style: pw.TextStyle(fontSize: 10.0)),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(1.5),
                  child: pw.Text('RBLR/MCLR= ${data['Rate of Interest'] ?? '---------'} %', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(1.5),
                  child: pw.Text('Any subsequent changes will be applicable accordingly.', style: pw.TextStyle(fontSize: 10.0)),
                ),
              ],
            ),
          ],
        ),
        _buildDataRow('Date of Maturity/Review', data['Date of Maturity/Review'] ?? ''),
      ],
    );
  }

  static pw.Widget _buildSection2(Map<String, String> data) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {0: const pw.FlexColumnWidth(0.4), 1: const pw.FlexColumnWidth(2.6)},
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(1.5),
              child: pw.Text('Repayment Terms', style: pw.TextStyle(fontSize: 10.0)),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(1.5),
                  child: pw.Text(
                    'Loan is repayable within ${data['Loan repayable months'] ?? '.........'} months from the date of sanction and the repayment schedule is as under:',
                    style: pw.TextStyle(fontSize: 10.0),
                  ),
                ),
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  children: [
                    pw.TableRow(
                      children: [
                        _buildCell('EMI', isHeader: true),
                        _buildCell('Number of EMIs', isHeader: true),
                        _buildCell('EMI Amt', isHeader: true),
                        _buildCell('Rs.', isHeader: true),
                        _buildCell('Commencement of repayment,', isHeader: true),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.SizedBox(),
                        _buildCell(data['Number of EMIs'] ?? ''),
                        pw.SizedBox(),
                        _buildCell(data['EMI Amt'] ?? ''),
                        _buildCell(data['Commencement of repayment'] ?? ''),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _buildCell('Overdraft'),
                        pw.SizedBox(),
                        _buildCell('As and when demand', span: 3),
                        pw.SizedBox(),
                        pw.SizedBox(),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _buildCell('Bullet Repayment'),
                        _buildCell('Lumpsum Amt'),
                        _buildCell('Rs.'),
                        _buildCell(data['Lumpsum Amt'] ?? '', span: 2),
                        pw.SizedBox(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSection3(Map<String, String> data) {
  return pw.Column(
    children: [
      pw.Table(
        border: pw.TableBorder.all(width: 0.5),
        columnWidths: {0: const pw.FlexColumnWidth(0.7), 1: const pw.FlexColumnWidth(2.3)},
        children: [
          _buildDataRow('Processing Charges', data['Processing Charges'] ?? ''),
          _buildDataRow('Gold Appraiser Charges', data['Gold Appraiser Charges'] ?? ''),
        ],
      ),
      pw.Table(
        border: pw.TableBorder.all(width: 0.5),
        columnWidths: {0: const pw.FlexColumnWidth(0.25), 1: const pw.FlexColumnWidth(2.75)},
        children: [
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(1.5),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Safe', style: pw.TextStyle(fontSize: 10.0)),
                    pw.Text('Keeping', style: pw.TextStyle(fontSize: 10.0)),
                    pw.Text('Charges:', style: pw.TextStyle(fontSize: 10.0)),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(1.5),
                    child: pw.Text('Applicable Charges:', style: pw.TextStyle(fontSize: 10.0)),
                  ),
                  pw.Table(
                    border: pw.TableBorder.all(width: 0.5),
                    children: [
                      pw.TableRow(
                        children: [
                          _buildCell('Loan Amount', isHeader: true),
                          _buildCell('Safe-keeping Charges', isHeader: true),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _buildCell('Up to Rs. 25000'),
                          _buildCell('Nil'),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _buildCell('Above 25000 to Rs.5.00 Lakh'),
                          _buildCell('Rs.150.00 per month or part thereof'),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _buildCell('Above Rs.5.00 Lakh'),
                          _buildCell('Rs.300.00 per month or part thereof'),
                        ],
                      ),
                    ],
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(1.5),
                    child: pw.Text(
                      'Note: Safe Keeping Charge will be applicable after 30 days of the expiry of the prescribed tenure of gold loan or after 30 days of closure of loan if jewels are not redeemed.',
                      style: pw.TextStyle(fontSize: 10.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      pw.Table(
        border: pw.TableBorder.all(width: 0.5),
        columnWidths: {0: const pw.FlexColumnWidth(2.3), 1: const pw.FlexColumnWidth(0.7)},
        children: [
          _buildDataRow('Charges related to issuing of notices for repayment, recovery or auction etc.', data['Notices Charges'] ?? ''),
          _buildDataRow('Charges of verification of land record', data['Land Record Charges'] ?? ''),
          _buildDataRow('Charges of verification of capturing crop image/Farm record', data['Crop image Charges'] ?? ''),
          _buildDataRow('Stamping/e-stamping/e-signing charges for execution of documents/ Digital lending charges', data['Stamping Charges'] ?? ''),
          _buildDataRow('Penal charges, if any, in case of delayed payment', data['Penal Charges'] ?? ''),
        ],
      ),
    ],
  );
}
  static pw.Widget _buildGoldDetailsPdfRow(List<Map<String, String>> goldData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.5),
          ),
          padding: const pw.EdgeInsets.all(1.5),
          child: pw.Text('Details of pledged Gold Ornaments/Coins', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10.0)),
        ),
        pw.Table(
          border: const pw.TableBorder(
            left: pw.BorderSide(width: 0.5),
            right: pw.BorderSide(width: 0.5),
            bottom: pw.BorderSide(width: 0.5),
            horizontalInside: pw.BorderSide(width: 0.5),
            verticalInside: pw.BorderSide(width: 0.5),
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(0.35), // Sr. No
            1: const pw.FlexColumnWidth(2.7), // Description
            2: const pw.FlexColumnWidth(1.1), // Gross Weight
            3: const pw.FlexColumnWidth(1.8), // Deductions
            4: const pw.FlexColumnWidth(1.1), // Net Weight
            5: const pw.FlexColumnWidth(0.9), // Fineness
            6: const pw.FlexColumnWidth(1.1), // Rate
            7: const pw.FlexColumnWidth(1.3), // Total
            8: const pw.FlexColumnWidth(1.4), // Condition
          },
          children: [
            pw.TableRow(
              children: [
                _buildCell('Sr. No', isHeader: true),
                _buildCell('Description of gold jewellery/ ornaments/ coins', isHeader: true),
                _buildCell('Gross Weight (in gram)', isHeader: true),
                _buildCell('Deductions (if any) stones, lac, alloy, strings, fastenings, etc', isHeader: true),
                _buildCell('Net Weight (in gram)', isHeader: true),
                _buildCell('Fineness/ Purity (in Carat)', isHeader: true),
                _buildCell('Valuation Rate per gram (Rs)', isHeader: true),
                _buildCell('Total Current Value (Rs)', isHeader: true),
                _buildCell('Condition of the jewelry (details of damage/ breakage, defects etc.)', isHeader: true),
              ],
            ),
            ...goldData.map((row) => pw.TableRow(
                  children: [
                    _buildCell(row['Sr. No'] ?? ''),
                    _buildCell(row['Description'] ?? ''),
                    _buildCell(row['Gross Weight'] ?? ''),
                    _buildCell(row['Deductions'] ?? ''),
                    _buildCell(row['Net Weight'] ?? ''),
                    _buildCell(row['Fineness'] ?? ''),
                    _buildCell(row['Valuation Rate'] ?? ''),
                    _buildCell(row['Total Value'] ?? ''),
                    _buildCell(row['Condition'] ?? ''),
                  ],
                )),
            if (goldData.isEmpty)
              for (int i = 1; i <= 3; i++)
                pw.TableRow(
                  children: [
                    _buildCell('$i'),
                    ...List.generate(8, (index) => _buildCell('')),
                  ],
                ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTermsPdfRow() {
    final terms = [
      'The loan shall be repayable on demand and shall be secured by the pledge of gold jewellery/ornaments/coins acceptable to the Bank.',
      'The Bank may, at its sole discretion and upon written request from the Borrower, permit repayment in instalments/interest/lumpsum payment. Such permission shall be without prejudice to the Bank\'s right to recall the entire outstanding dues at any time.',
      'The pledged gold jewellery/ornaments/coins shall be valued by an appraiser appointed by the Bank, in accordance with applicable regulatory guidelines. The cost of valuation shall be borne by the Borrower.',
      'The Borrower acknowledges and consents that the pledged gold may be periodically inspected, re-appraised, or revalued by the Bank, including by its internal/external auditors or appraisers, as required under regulatory or Bank guidelines.',
      'The Borrower irrevocably authorizes the Bank to open sealed packets containing the pledged gold ornaments/articles in the absence of the Borrower, for inspection or revaluation purposes, without further notice. The revised value determined by the Bank\'s authorized valuer shall be final and binding.',
      'The Borrower shall maintain the prescribed LTV ratio throughout the tenure of the loan, as stipulated by the Bank in line with RBI guidelines.',
      'Borrower shall promptly provide the required margin or repayment to regularize the loan. Upon failure to comply, the Bank shall have the right to auction the pledged gold articles, in accordance with applicable RBI guidelines.',
      'The Bank shall have the right to retain, appropriate, or sell the pledged gold and adjust the proceeds not only against this loan but also against any other liability of the Borrower with the Bank, whether as Borrower or Guarantor.',
      'The Borrower shall execute all loan, pledge, and security documents as required by the Bank from time to time, at the Borrower\'s own cost, including applicable stamp duty and charges.',
      'If the loan is not repaid within the stipulated tenure, annual review charges shall be levied, equivalent to the processing charges applicable at the time of original sanction, or as revised by the Bank.',
      'The pledged gold ornaments/jewellery/coins shall be collected by the Borrower within 7 working days from the date of full repayment/settlement of the loan. In case the Borrower is unable to visit the branch, the Borrower shall inform the sanctioning branch in writing with valid reasons within 7 days of full repayment/settlement of the loan.',
      'If the pledged gold is not redeemed within 30 days from the date of loan closure or prescribed tenure, safe-keeping charges shall be levied as per the Bank\'s schedule of charges.',
      'By acknowledging this sanction letter, the Borrower agrees that any notice given to the Borrower on the address provided to the Bank should be sufficient notice irrespective of actual receipt by the Borrower. Hence, any notice served to the address provided by the borrower to the Bank shall be treated as valid and sufficient.',
      'The terms stated in the Loan-cum-Agreement of Pledge, this sanction letter, and any additional terms stipulated by the Bank or regulatory authorities from time to time shall be binding on the Borrower.',
    ];

    return pw.Column(
      children: [
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: {0: const pw.FlexColumnWidth(0.25), 1: const pw.FlexColumnWidth(2.65)},
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(1.5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Other', style: pw.TextStyle(fontSize: 10.0)),
                      pw.Text('Terms', style: pw.TextStyle(fontSize: 10.0)),
                      pw.Text('and', style: pw.TextStyle(fontSize: 10.0)),
                      pw.Text('Condition', style: pw.TextStyle(fontSize: 10.0)),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(1),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: terms
                        .map((term) => pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
                                pw.Expanded(child: pw.Text(term, style: pw.TextStyle(fontSize: 10.0))),
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.5),
          ),
          padding: const pw.EdgeInsets.all(1.5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'This sanction letter shall be read and construed as part and parcel of the loan documents executed by the borrower of the loan mentioned here in.',
                style: pw.TextStyle(fontSize: 10.0),
              ),
              pw.Text(
                'This sanction letter is integral to the loan documentation and shall be read in concurrence with all signed agreements and declarations.',
                style: pw.TextStyle(fontSize: 10.0),
              ),
            ],
          ),
        ),
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(1.5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('For Bank of India', style: pw.TextStyle(fontSize: 10.0)),
                      pw.Text('Manager', style: pw.TextStyle(fontSize: 10.0)),
                      pw.SizedBox(height: 5),
                      pw.Text('Date:', style: pw.TextStyle(fontSize: 10.0)),
                      pw.Text('Place:', style: pw.TextStyle(fontSize: 10.0)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          children: [
            pw.TableRow(
              children: [
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(1.5),
                    child: pw.Text('Acknowledgement', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
                  ),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(1.5),
                  child: pw.Text(
                    'I/We hereby confirm acceptance of the loan sanction and agree to abide by the terms and conditions above including the Loan cum Pledge Agreement and other general conditions as applicable to the gold loan.',
                    style: pw.TextStyle(fontSize: 10.0),
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.0), // Date/Place label
            1: const pw.FlexColumnWidth(2.0), // Signature label box
          },
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1, horizontal: 1.5),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Date:', style: pw.TextStyle(fontSize: 10.0)),
                      pw.SizedBox(height: 5),
                      pw.Text('Place:', style: pw.TextStyle(fontSize: 10.0)),
                    ],
                  ),
                ),
                pw.Container(
                  height: 30,
                  alignment: pw.Alignment.bottomCenter,
                  padding: const pw.EdgeInsets.all(0.7),
                  child: pw.Text('Signature of the borrower', style: pw.TextStyle(fontSize: 10.0)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildKfsHeader() {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('Annexure- IVC', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
          ],
        ),
        pw.SizedBox(height: 5), 
        pw.Center(child: pw.Text('BANK OF INDIA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0))),
        pw.Center(
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(
                width: 60,
                decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
              ),
              pw.Text(' BRANCH', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
            ],
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Center(
          child: pw.Text(
            'GOLD LOAN KEY FACT STATEMENT (KFS) (Applicable for Retail and MSME Gold Loans)',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0, decoration: pw.TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildKfsTable(Map<String, String> data) {
    return pw.Column(
      children: [
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(0.15), // Sr. No
            1: const pw.FlexColumnWidth(2.8), // Description + Data
          },
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(0.2),
                  child: pw.Text('Part I:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.0)),
                ),
                pw.SizedBox(),
              ],
            ),
            _buildKfsRow('1', 'Loan proposal/ account No.', data['Loan Account Number'] ?? '', 'Type of Loan', 'Retail/MSME', 2.8, 4.8, 1.2, 1.2),
            _buildKfsRow('2', 'Sanctioned Loan amount (in Rupees)', data['Sanctioned Loan Amount'] ?? ''),
            _buildKfsRow('3', 'Disbursal schedule(i) Disbursement in stages or 100% upfront.', ''),
            _buildKfsRow('4', 'Loan term (year/months/days)', '${data['Loan Term in months'] ?? '---'} '),
            pw.TableRow(
              children: [
                _buildNumberCell('5'),
                pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(1.5),
                            child: pw.Text('Instalment details', style: pw.TextStyle(fontSize: 10.0)),
                          ),
                        ),
                      ],
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(width: 0.5),
                      children: [
                        pw.TableRow(
                          children: [
                            _buildCell('EMI', isHeader: true),
                            _buildCell('Number of EMIs', isHeader: true),
                            _buildCell('EMI (\u20B9)', isHeader: true),
                            _buildCell('Commencement of repayment, post sanction', isHeader: true),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.SizedBox(),
                            _buildCell(data['Number of EMIs'] ?? ''),
                            _buildCell(data['EMI Amt'] ?? ''),
                            _buildCell(data['Commencement of repayment'] ?? ''),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            _buildCell('Overdraft'),
                            _buildCell('As and when demand', span: 2),
                            pw.SizedBox(),
                            pw.SizedBox(),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            _buildCell('Bullet Repayemnt'),
                            _buildCell('LUMPSUM'),
                            _buildCell('Rs.'),
                            pw.SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            _buildKfsRow('6', 'Interest rate (%) and type (floating)', '${data['Rate of Interest'] ?? '---'} % (Floating)'),
            pw.TableRow(
              children: [
                _buildNumberCell('7'),
                pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(1.5),
                            child: pw.Text('Additional Information in case of Floating rate of interest', style: pw.TextStyle(fontSize: 10.0)),
                          ),
                        ),
                      ],
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(width: 0.5),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(0.4), // Reference Benchmark
                        1: const pw.FlexColumnWidth(0.4), // Benchmark rate
                        2: const pw.FlexColumnWidth(0.4), // Spread
                        3: const pw.FlexColumnWidth(0.4), // Final rate
                        4: const pw.FlexColumnWidth(0.5), // Reset periodicity
                        5: const pw.FlexColumnWidth(1.2), // Impact
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            _buildCell('Reference\nBenchmark', isHeader: true),
                            _buildCell('Benchmark\nrate (%) (B)', isHeader: true),
                            _buildCell('Spread\n(%) (S)', isHeader: true),
                            _buildCell('Final rate\n(%) R = \n(B) + (S)', isHeader: true),
                            _buildCell('Reset\nperiodicity\n@ (Months)', isHeader: true),
                            _buildCell('Impact of change in the reference benchmark (for 25 bps change in \'R\', change in:#)', isHeader: true),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.SizedBox(),
                            pw.SizedBox(),
                            pw.SizedBox(),
                            pw.SizedBox(),
                            pw.Table(
                              border: pw.TableBorder.all(width: 0.5),
                              children: [
                                pw.TableRow(
                                  children: [_buildCell('B'), _buildCell('S')],
                                ),
                              ],
                            ),
                            pw.Table(
                              border: pw.TableBorder.all(width: 0.5),
                              children: [
                                pw.TableRow(
                                  children: [_buildCell('EMI (\u20B9)'), _buildCell('No. of EMIs')],
                                ),
                              ],
                            ),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            _buildCell('RBLR/MCLR'),
                            _buildCell(data['Rate of Interest'] ?? ''),
                            _buildCell('0.00'),
                            _buildCell(data['Rate of Interest'] ?? ''),
                            _buildCell(''),
                            _buildCell(''),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.TableRow(
              children: [
                _buildNumberCell('8'),
                pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0.1),
                            child: pw.Text('Fee/ Charges', style: pw.TextStyle(fontSize: 10.0)),
                          ),
                        ),
                      ],
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(width: 0.2),
                      columnWidths: {0: const pw.FlexColumnWidth(0.10), 1: const pw.FlexColumnWidth(0.45), 2: const pw.FlexColumnWidth(3.17)},
                      children: [
                        pw.TableRow(
                          children: [
                            _buildCell('i.'),
                            _buildCell('Processing\nfees'),
                            pw.Table(
                              border: pw.TableBorder.all(width: 0.5),
                              columnWidths: {0: const pw.FlexColumnWidth(1.6), 1: const pw.FlexColumnWidth(2.4)},
                              children: [
                                pw.TableRow(
                                  children: [
                                    _buildCell('Limit', isHeader: true),
                                    _buildCell('PPC', isHeader: true),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    _buildCell('Up to Rs.0.50 lakh'),
                                    _buildCell('For PSL accounts- NIL For other than PSL Rs. 250 /- +GST.'),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    _buildCell('Above Rs.0.50 lakh to Rs.1.00 lakh'),
                                    _buildCell('Rs.250/-+ Applicable GST'),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    _buildCell('Above Rs.1.00 lakh to Rs.5.00 lakh'),
                                    _buildCell('Rs.500/-+ Applicable GST'),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    _buildCell('Above Rs.5.00 lakh to Rs.10.00 lakh'),
                                    _buildCell('Rs.1000/-+ Applicable GST'),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    _buildCell('Above Rs.10.00 lakhs'),
                                    _buildCell('Rs.1500/-+ Applicable GST'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            _buildCell('ii.'),
                            _buildCell('Valuations\nfees'),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(0.2),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildBulletPoint('Rs.5/- per Rs.1000/- of loan amount (Minimum Rs.100/- ; Maximum Rs.1500/- for loans up to Rs.10 Lakh).'),
                                  _buildBulletPoint('For loans above Rs.10 Lakh: Flat Rs.2000.'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Table(
                      border: const pw.TableBorder(
                        bottom: pw.BorderSide(width: 0.2),
                        left: pw.BorderSide(width: 0.2),
                        right: pw.BorderSide(width: 0.2),
                        verticalInside: pw.BorderSide(width: 0.2),
                        horizontalInside: pw.BorderSide(width: 0.2),
                      ),
                      columnWidths: {0: const pw.FlexColumnWidth(0.12), 1: const pw.FlexColumnWidth(0.60), 2: const pw.FlexColumnWidth(3.28)},
                      children: [
                        pw.TableRow(
                          children: [
                            _buildCell('iii.'),
                            _buildCell('Annual review charges'),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(0.2),
                              child: pw.Text(
                                'If loan is not repaid within the stipulated time period, annual Review charges will be applicable which are equivalent to processing charges levied at the time of original sanction.',
                                style: pw.TextStyle(fontSize: 9.0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Table(
                      border: const pw.TableBorder(
                        bottom: pw.BorderSide(width: 0.2),
                        left: pw.BorderSide(width: 0.2),
                        right: pw.BorderSide(width: 0.2),
                        verticalInside: pw.BorderSide(width: 0.2),
                        horizontalInside: pw.BorderSide(width: 0.2),
                      ),
                      columnWidths: {0: const pw.FlexColumnWidth(0.08), 1: const pw.FlexColumnWidth(0.32), 2: const pw.FlexColumnWidth(3.60)},
                      children: [
                        pw.TableRow(
                          children: [
                            _buildCell('iv.'),
                            _buildCell('Safe\nkeeping\ncharges'),
                            pw.Column(
                              children: [
                                pw.Table(
                                  border: pw.TableBorder.all(width: 0.5),
                                  columnWidths: {0: const pw.FlexColumnWidth(1.6), 1: const pw.FlexColumnWidth(2.4)},
                                  children: [
                                    pw.TableRow(
                                      children: [
                                        _buildCell('Loan Amount', isHeader: true),
                                        _buildCell('Safe-keeping Charges', isHeader: true),
                                      ],
                                    ),
                                    pw.TableRow(
                                      children: [
                                        _buildCell('Up to Rs. 50,000/-'),
                                        _buildCell('Nil'),
                                      ],
                                    ),
                                    pw.TableRow(
                                      children: [
                                        _buildCell('Above Rs.50,000/- to Rs.5.00 Lakh'),
                                        _buildCell('Rs.150.00 +GST per month or part thereof'),
                                      ],
                                    ),
                                    pw.TableRow(
                                      children: [
                                        _buildCell('Above Rs.5.00 Lakh'),
                                        _buildCell('Rs.300.00 +GST per month or part thereof'),
                                      ],
                                    ),
                                  ],
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(0.2),
                                  child: pw.Text(
                                    'Applicable after 30 days of the expiry of the prescribed tenure of gold loan or after 30 days of closure of loan if jewels are not redeemed',
                                    style: pw.TextStyle(fontSize: 10.0, fontStyle: pw.FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Table(
                      border: const pw.TableBorder(
                        bottom: pw.BorderSide(width: 0.2),
                        left: pw.BorderSide(width: 0.2),
                        right: pw.BorderSide(width: 0.2),
                        verticalInside: pw.BorderSide(width: 0.2),
                        horizontalInside: pw.BorderSide(width: 0.2),
                      ),
                      columnWidths: {0: const pw.FlexColumnWidth(0.10), 1: const pw.FlexColumnWidth(1.0), 2: const pw.FlexColumnWidth(2.62)},
                      children: [
                        pw.TableRow(
                          children: [
                            _buildCell('v.'),
                            _buildCell('Stamping charges'),
                            _buildCell('Applicable as per respective state laws.'),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            _buildCell('vi.'),
                            _buildCell('Digital lending charges'),
                            _buildCell('e-stamping & e signing charges'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            _buildNumberedRow('9', 'Annual Percentage Rate (APR) *', data['APR'] ?? ''),
            pw.TableRow(
              children: [
                _buildNumberCell('10'),
                pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 32,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 0.5))),
                            padding: const pw.EdgeInsets.all(0.2),
                            child: pw.Text('Details of Contingent Charges (in \u20B9 or %, as applicable)', style: pw.TextStyle(fontSize: 10.0)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 68,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0.2),
                            child: pw.Text('For Agriculture gold loans: Land details fetching charges of Rs. 50/- and For capturing of crop image/history @ Rs. 75 /- per account.',
                                style: pw.TextStyle(fontSize: 10.0)),
                          ),
                        ),
                      ],
                    ),
                    pw.Table(
                      border: pw.TableBorder(top: const pw.BorderSide(width: 0.5)),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Container(
                              width: 30,
                              height: 15,
                              decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 0.5))),
                              alignment: pw.Alignment.center,
                              child: pw.Text('i)', style: pw.TextStyle(fontSize: 10.0)),
                            ),
                            pw.Expanded(
                              flex: 50,
                              child: pw.Container(
                                decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 0.5))),
                                padding: const pw.EdgeInsets.all(0.5),
                                child: pw.Text('Penal charges, if any, in case of delayed payment', style: pw.TextStyle(fontSize: 10.0)),
                              ),
                            ),
                            pw.Expanded(
                              flex: 50,
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(0.5),
                                child: pw.Text('As per bank\'s extant guidelines.', style: pw.TextStyle(fontSize: 10.0)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            _buildKfsRow('11', 'Auction charges', 'Charges to be incurred during process of auction.', null, null, 40, 64),

            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(0.2),
                  child: pw.Text('Part II:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
                ),
                pw.SizedBox(),
              ],
            ),
            _buildNumberedRow('1', 'Clause of Loan agreement relating to engagement of recovery agents', ''),
            _buildNumberedRow('2', 'Clause of Loan agreement which details grievance redressal mechanism', ''),
            _buildNumberedRow('3', 'Phone number and email id of the nodal grievance redressal officer', ''),
            _buildNumberedRow('4', 'Whether the loan is or in future maybe, subject to transfer to another Res or Securitizations (Yes/No)', ''),
            pw.TableRow(
              children: [
                _buildNumberCell('5'),
                pw.Column(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(0.2),
                      child: pw.Text('In case lending under collaborative lending arrangements (e.g. co-lending/outsourcing), following additional details may be furnished', style: pw.TextStyle(fontSize: 10.0)),
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(width: 0.5),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(1),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            _buildCell('Name of the originating RE, along with its funding proportion', isHeader: true),
                            _buildCell('Name of the partner RE, along with its proportion of funding', isHeader: true),
                            _buildCell('Blended rate of interest', isHeader: true),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.SizedBox(height: 1),
                            pw.SizedBox(),
                            pw.SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.TableRow(
              children: [
                _buildNumberCell('6'),
                pw.Column(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(0.2),
                      child: pw.Text('In case of digital loans, following specific disclosures may be furnished:', style: pw.TextStyle(fontSize: 10.0)),
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(width: 0.5),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Expanded(
                              flex: 3,
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(0.2),
                                child: pw.Text('(i) Cooling off/look-up period, in terms of RE\'s board approved policy, during which borrower shall not be charged any penalty on prepayment of loan', style: pw.TextStyle(fontSize: 10.0)),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.SizedBox(),
                            ),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Expanded(
                              flex: 3,
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(0.2),
                                child: pw.Text('(ii) Details of LSP acting as recovery agent and authorized to approach the borrower.', style: pw.TextStyle(fontSize: 10.0)),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.SizedBox(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildNumberedRow(String num, String label, String value) {
    return pw.TableRow(
      children: [
        _buildNumberCell(num),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 6, 
              child: pw.Container(
                decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 0.5))),
                padding: const pw.EdgeInsets.all(0.2), 
                child: pw.Text(label, style: pw.TextStyle(fontSize: 10.0)),
              ),
            ),
            pw.Expanded(
              flex: 1, 
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(0.2),
                child: pw.Text(value, style: pw.TextStyle(fontSize: 10.0)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildKfsRow(String num, String label, String value, [String? label2, String? value2, double f1 = 7, double f2 = 2, double f3 = 3, double f4 = 3]) {
    return pw.TableRow(
      children: [
        _buildNumberCell(num),
        pw.Table(
          border: const pw.TableBorder(verticalInside: pw.BorderSide(width: 0.5)),
          columnWidths: {
            0: pw.FlexColumnWidth(f1),
            1: pw.FlexColumnWidth(f2),
            if (label2 != null) 2: pw.FlexColumnWidth(f3),
            if (label2 != null) 3: pw.FlexColumnWidth(f4),
          },
          children: [
            pw.TableRow(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(0.2),
                  child: pw.Text(label, style: pw.TextStyle(fontSize: 10.0)),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(0.2),
                  child: pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
                ),
                if (label2 != null) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(0.2),
                    child: pw.Text(label2, style: pw.TextStyle(fontSize: 10.0)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(0.2),
                    child: pw.Text(value2 ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildNumberCell(String num) {
    return pw.Center(
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(0.2),
        child: pw.Text(num, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
      ),
    );
  }

  static pw.Widget _buildBulletPoint(String text) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
        pw.Expanded(child: pw.Text(text, style: pw.TextStyle(fontSize: 10.0))),
      ],
    );
  }

  static pw.TableRow _buildDataRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(1.5),
          child: pw.Text(label, style: pw.TextStyle(fontSize: 10.0)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(1.5),
          child: pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
        ),
      ],
    );
  }

  static pw.Widget _buildAprFactsheet(Map<String, String> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Consolidated Header Box
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.5),
          ),
          padding: const pw.EdgeInsets.all(2),
          alignment: pw.Alignment.center,
          child: pw.Text('Illustrative Factsheet on computation of APR for Agriculture Loans', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
        ),
        pw.Container(
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              left: pw.BorderSide(width: 0.5),
              right: pw.BorderSide(width: 0.5),
              bottom: pw.BorderSide(width: 0.5),
            ),
          ),
          padding: const pw.EdgeInsets.all(1),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Applicant Name: ________________________________', style: pw.TextStyle(fontSize: 10.0)),
              pw.Text('Lender\'s Name: ________________________________', style: pw.TextStyle(fontSize: 10.0)),
              pw.Text('Date: ________________________________', style: pw.TextStyle(fontSize: 10.0)),
              pw.Text('Amt in Rs.', style: pw.TextStyle(fontSize: 10.0)),
            ],
          ),
        ),
        // Parameters Table
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(0.2), // Sr. No
            1: const pw.FlexColumnWidth(4.4), // Parameter
            2: const pw.FlexColumnWidth(0.4), // Details
          },
          children: [
            pw.TableRow(
              children: [
                _buildCell('Sr.\nNo.', isHeader: true),
                _buildCell('Parameter', isHeader: true),
                _buildCell('Details', isHeader: true),
              ],
            ),
            _buildAprRow('1', 'Sanctioned Loan amount', data['Sanctioned Loan amount'] ?? ''),
            _buildAprRow('2', 'Loan Term (in years/ months/ days)', data['Loan Term'] ?? ''),
            _buildAprRow('a)', 'No. of instalments for payment of principal, in case of non-equated periodic loans', ''),
            _buildAprRow('b)', '• Type of EMI\n• Amount of each EMI and\n• nos. of EMIs (e.g., no. of EMIs in case of monthly instalments)', ''),
            _buildAprRow('c)', 'No. of instalments for payment of capitalized interest, if any', ''),
            _buildAprRow('d)', 'Commencement of repayments, post sanction', ''),
            _buildAprRow('3', 'Interest rate type', ''),
            _buildAprRow('4', 'Rate of Interest', '${data['Rate of Interest'] ?? '---'} '),
            _buildAprRow('5', 'Total Interest Amount to be charged during the entire tenor of the loan as per the rate prevailing on sanction date', ''),
            _buildAprRow('6', 'Fee/ Charges payable*', ''),
            _buildAprRow('A', 'Payable to the Bank', ''),
            _buildAprRow('B', 'Payable to Gold appraiser', ''),
            _buildAprRow('C', 'Stamp Duty & Digital lending charges', ''),
            _buildAprRow('7', 'Net disbursed amount (1-6)', ''),
            _buildAprRow('8', 'Total amount to be paid by the borrower (sum of 1 and 5)', ''),
            _buildAprRow('9', 'Annual Percentage rate- Effective annualized interest rate (in percentage)', data['APR'] ?? ''),
          ],
        ),
        pw.Table(
          border: const pw.TableBorder(
            bottom: pw.BorderSide(width: 0.5),
            left: pw.BorderSide(width: 0.5),
            right: pw.BorderSide(width: 0.5),
            verticalInside: pw.BorderSide(width: 0.5),
            horizontalInside: pw.BorderSide(width: 0.5),
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(0.2), // Sr. No
            1: const pw.FlexColumnWidth(2.8), // Parameter
            2: const pw.FlexColumnWidth(2.0), // Details
          },
          children: [
            pw.TableRow(
              children: [
                _buildNumberCell('10'),
                _buildCell('Schedule of disbursement as per terms and conditions', textAlign: pw.TextAlign.left),
                _buildCell('Disbursement in stages or 100% upfront', fontSize: 10.0),
              ],
            ),
          ],
        ),
        pw.Table(
          border: const pw.TableBorder(
            bottom: pw.BorderSide(width: 0.5),
            left: pw.BorderSide(width: 0.5),
            right: pw.BorderSide(width: 0.5),
            verticalInside: pw.BorderSide(width: 0.5),
            horizontalInside: pw.BorderSide(width: 0.5),
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(0.2), // Sr. No
            1: const pw.FlexColumnWidth(4.4), // Parameter
            2: const pw.FlexColumnWidth(0.4), // Details
          },
          children: [
            _buildAprRow('11', 'Due date of payment of instalment and interest', ''),
            _buildAprRow('11', 'Rate of interest for unhedged foreign currency loan', ''),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Note: -Stamp Duty & Digital lending charges will need be paid upfront.\nIn case of dispute, the borrower can call No.__________ or write to ________________________________',
          style: pw.TextStyle(fontSize: 10.0),
        ),
        pw.SizedBox(height: 5),
        pw.Wrap(
          children: [
            pw.Text('Repayment Schedule for EMI Loans:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              children: [
                pw.TableRow(
                  children: [
                    _buildCell('Instalment No.', isHeader: true),
                    _buildCell('Outstanding Principal', isHeader: true),
                    _buildCell('Principal', isHeader: true),
                    _buildCell('Interest', isHeader: true),
                    _buildCell('Instalment', isHeader: true),
                  ],
                ),
                ...List.generate(12, (index) => pw.TableRow(
                  children: [
                    _buildCell('${index + 1}'),
                    _buildCell(''),
                    _buildCell(''),
                    _buildCell(''),
                    _buildCell(''),
                  ],
                )),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildAprRow(String num, String parameter, String details) {
    return pw.TableRow(
      children: [
        _buildNumberCell(num),
        pw.Padding(
          padding: const pw.EdgeInsets.all(0.2),
          child: pw.Text(parameter, style: pw.TextStyle(fontSize: 10.0)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(0.2),
          child: pw.Text(details, style: pw.TextStyle(fontSize: 10.0)),
        ),
      ],
    );
  }

  static pw.Widget _buildPostSanctionReport(Map<String, String> data) {
    return pw.Column(
      children: [
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.2),
            1: const pw.FlexColumnWidth(1.8),
          },
          children: [
            pw.TableRow(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text('Post Sanction Inspection Report', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
                  ),
                ),
                pw.SizedBox(), // Dummy for span simulation
              ],
            ),
            _buildPostRow('Branch Name', data['Branch Name'] ?? ''),
            _buildPostRow('Name of the Borrower', data['Borrower Name'] ?? ''),
            _buildPostRow('Address', data['Borrower Address'] ?? ''),
            _buildPostRow('Loan Account Number', data['Loan Account Number'] ?? ''),
            _buildPostRow('Sanction Limit', data['Sanction Limit'] ?? ''),
            _buildPostRow('Purpose of Loan', ''),
            _buildPostRow('Sanction Date', data['Sanction Date'] ?? ''),
            _buildPostRow('Name of the Inspecting Officer', ''),
            _buildPostRow('Date of Inspection', ''),
            pw.TableRow(
              children: [
                _buildCell('End Use of the fund', textAlign: pw.TextAlign.left, fontSize: 10.0),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Container(
                        decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 0.5))),
                        child: _buildCell('Satisfactory', textAlign: pw.TextAlign.center, fontSize: 10.0),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: _buildCell('Unsatisfactory', textAlign: pw.TextAlign.center, fontSize: 10.0),
                    ),
                  ],
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    height: 20,
                    padding: const pw.EdgeInsets.all(1),
                    alignment: pw.Alignment.topLeft,
                    child: pw.Text('Inspection Findings', style: pw.TextStyle(fontSize: 10.0)),
                  ),
                ),
                pw.SizedBox(),
              ],
            ),
            pw.TableRow(
              children: [
                pw.SizedBox(height: 26),
                pw.Container(
                  height: 26,
                  alignment: pw.Alignment.bottomCenter,
                  child: pw.Text('Signature of the Inspecting Officer', style: pw.TextStyle(fontSize: 10.0)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildPostRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 0.5, vertical: 0.2),
          child: pw.Text(label, style: pw.TextStyle(fontSize: 10.0)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 0.5, vertical: 0.2),
          child: pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.0)),
        ),
      ],
    );
  }

  static pw.Widget _buildCell(String text, {bool isHeader = false, int span = 1, pw.TextAlign textAlign = pw.TextAlign.center, double? fontSize}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(0.2),
      child: pw.Text(
        text,
        textAlign: textAlign,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: fontSize ?? 10.0,
        ),
      ),
    );
  }
}
