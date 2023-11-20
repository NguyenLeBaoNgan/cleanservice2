import 'dart:convert';

import 'package:cleanservice/models/transaction.dart';
import 'package:cleanservice/network/uri_api.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../models/appointment.dart';
import '../../models/pref_profile_model.dart';
import '../../models/service_model.dart';
import '../../models/user_model.dart';
import '../homectv.dart';
import '../mainctv.dart';
import 'ctdv2.dart';

class ThongTin extends StatefulWidget {
  final Appointment appointment;
  final User user;
  ThongTin({required this.appointment, required this.user});

  @override
  State<ThongTin> createState() => _ThongTinState();
}

class _ThongTinState extends State<ThongTin> {
  late String paymentMethod = "";
  late String statusPay = "";
  late TransactionStatus transactionStatus;
  List<TransactionStatus> transactionStatusList = [];

  void _viewMap(String address) async {
    final String url = "https://maps.google.com/?q=${Uri.encodeFull(address)}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Không thể mở bản đồ: $url';
    }
  }

  Future<void> _updateStatus() async {
    final idAppointment = widget.appointment.idAppointment;
    final response = await http.post(
      Uri.parse(BASEURL.getstatus),
      body: {
        'id_appointment': idAppointment,
      },
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);

      if (responseJson['value'] == 1) {
        final newStatus = responseJson['new_status'];
        setState(() {
          widget.appointment.status = newStatus.toString();
        });
      } else {
        // Handle error when updating status is unsuccessful
      }
    } else {
      // Handle error when unable to connect to the API
    }
  }

  Future<void> fetchAllTransactionData() async {
    try {
      Uri urlTransaction = Uri.parse(BASEURL.transaction);

      final response = await http.get(urlTransaction);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          transactionStatusList = List<TransactionStatus>.from(data.map((item) {
            return TransactionStatus.fromJson(item);
          }));
          setState(() {});
        } else {
          print('No transaction data found');
        }
      } else {
        print(
            'Failed to fetch transaction data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching transaction data: $error');
    }
  }

  String getStatusPay(String? statuspay) {
    return (statuspay == '1') ? "Đã thanh toán" : "Chưa thanh toán";
  }

  TransactionStatus getTransactionStatusForAppointment(
      Appointment appointment) {
    return transactionStatusList.firstWhere(
      (transaction) => transaction.idAppointment == appointment.idAppointment,
      orElse: () => TransactionStatus(),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchAllTransactionData();
  }

  @override
  Widget build(BuildContext context) {
    transactionStatus = getTransactionStatusForAppointment(widget.appointment);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết dịch vụ"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dịch vụ: ${widget.appointment.serviceName}',
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.0),
              Text(
                'Kích thước phòng: ${widget.appointment.roomSize}',
                style: TextStyle(fontSize: 17.0),
              ),
              SizedBox(height: 12.0),
              Text(
                'Giờ làm: ${widget.appointment.datetime}',
                style: TextStyle(fontSize: 17.0),
              ),
              SizedBox(height: 12.0),
              Text(
                'Phương thức thanh toán: ${transactionStatus.paymentMethod}',
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.0),
              Text(
                'Tình trạng thanh toán: ${getStatusPay(transactionStatus.statusPay)}',
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.0),
              Text(
                'Thông tin',
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.0),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildUserRow(),
                    SizedBox(height: 12.0),
                    Text(
                      'Địa chỉ: ${widget.appointment.userAddress}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      'SDT: ${widget.appointment.userPhone}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      'Mô tả: ${widget.appointment.description}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      'Mức độ bẩn: ${widget.appointment.dirtLevel}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.0),
              Center(
                child: Text(
                  'Tổng tiền: ${widget.appointment.price}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.green[800],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _updateStatus();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPageAd(),
                      ),
                    );
                  },
                  child: Text('Tiếp tục'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserRow() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tên khách hàng: ${widget.appointment.userName}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
          ),
          TextButton(
            onPressed: () {
              _viewMap(widget.appointment.userAddress.toString());
            },
            child: Text(
              'Xem bản đồ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
