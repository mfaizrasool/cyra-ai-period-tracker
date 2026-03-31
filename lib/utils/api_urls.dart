class ApiUrls {
  static const String baseUrl = "https://foldious.com/api";

  ///
  static const String login = "/authentication/login.php";
  static const String register = "/authentication/register.php";
  static const String forgetPassword = "/authentication/forgot_password.php";
  static const String userDetails = "/authentication/user_details.php";
  static const String updateUser = "/authentication/update_user.php";
  static const String profileUpdate = "/authentication/profile_update.php";
  static const String deleteUser = "/authentication/delete_user.php";
  static const String updatePassword = "/authentication/update_password.php";

  /* -------------------------------------------------------------------------- */
  /*                                   image                                   */
  /* -------------------------------------------------------------------------- */
  static const String uploadImage = "/image/upload_image.php";
  static const String fetchImages = "/image/fetch_image.php";
  static const String trashDelete = "/image/trash_delete.php";
  static const String favoriteToggle = "/favorite/favorite_toggle.php";
  static const String favoriteList = "/favorite/favorite_list.php";
  static const String folderAdd = "/folder/folder_add.php";
  static const String folderFetch = "/folder/folder_fetch.php";
  static const String folderDelete = "/folder/folder_delete.php";
  static const String folderUpdate = "/folder/folder_update.php";
  static const String shareManager = "/folder/share_manager.php";

  /* -------------------------------------------------------------------------- */
  /*                        settings and others                                 */
  /* -------------------------------------------------------------------------- */
  static const String about = "/others/about.php";
  // static const String settings = "/others/settings.php";

  /* -------------------------------------------------------------------------- */
  /*                                notifications                               */
  /* -------------------------------------------------------------------------- */
  static const String getNotifications = "/notification/get_notifications.php";
  static const String updateNotificationStatus =
      "/notification/update_notification_status.php";

  /* -------------------------------------------------------------------------- */
  /*                                    refer                                   */
  /* -------------------------------------------------------------------------- */
  static const String referalListView = "/referal/referal_list_view.php";
  static const String requestWithdraw = "/referal/request_withdraw.php";
  static const String addReferal = "/referal/add_referal.php";
  static const String withdrawStatus = "/referal/withdraw_status.php";

  /* -------------------------------------------------------------------------- */
  /*                                   edit image                               */
  /* -------------------------------------------------------------------------- */
  static const String kieApiBaseUrl = "https://api.kie.ai/api/v1";
  static const String editImage = "/jobs/createTask";
  static const String recordInfo = "/jobs/recordInfo";

  /* -------------------------------------------------------------------------- */
  /*                                 workflow                                   */
  /* -------------------------------------------------------------------------- */
  static const String workflowFetchPending = "/workflow/fetch_pending.php";

  /* -------------------------------------------------------------------------- */
  /*                                   video                                    */
  /* -------------------------------------------------------------------------- */
  static const String fetchVideos = "/video/fetch.php";

  /* -------------------------------------------------------------------------- */
  /*                          ImageKit video upload                             */
  /* -------------------------------------------------------------------------- */
  static const String imageKitUploadUrl =
      'https://upload.imagekit.io/api/v1/files/upload';
  static const String imageKitPublicKey = 'public_ubwAwYO8qZXsxyexKkSjpc5UrPY=';
  static const String imageKitPrivateKey =
      'private_lrG3ZtcSbvtO5K9euXFHO0+RzV0=';

  /* -------------------------------------------------------------------------- */
  /*                                 n8n webhook (single combine workflow)      */
  /* -------------------------------------------------------------------------- */
  /// Single webhook for all AI actions. Send `type` and payload; workflow record is created in n8n.
  static const String n8nCombineWorkflowWebhookUrl =
      "https://n8nvps.alkasirscrap.com/webhook/combine-workflow";
}
