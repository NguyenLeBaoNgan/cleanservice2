class BASEURL {
  static String ipAddress = "192.168.1.6";
  static String apiRegister =
      "http://$ipAddress/testclean1_db/register_api.php";
  static String apiLogin = "http://$ipAddress/testclean1_db/login_api.php";
  static String getService = "http://$ipAddress/testclean1_db/get_service.php";
  static String appointments =
      "http://$ipAddress/testclean1_db/appointments.php";
  static String history =
      "http://$ipAddress/testclean1_db/get_history.php?id_user=";
  static String receive = "http://$ipAddress/testclean1_db/receive.php";
  static String get_appointments =
      "http://$ipAddress/testclean1_db/get_appointments.php";
  static String getstatus = "http://$ipAddress/testclean1_db/status.php";
  // static String xulythanhtoanmomo =
  //     "http://$ipAddress/testclean1_db/xulythanhtoanmomo.php";
  // static String momo = "http://$ipAddress/testclean1_db/momo.php";
  static String pay = "http://$ipAddress/testclean1_db/transaction_status.php";
  static String transaction =
      "http://$ipAddress/testclean1_db/get_transaction.php";
  static String deleteapp =
      "http://$ipAddress/testclean1_db/delete_appointment.php";
}
