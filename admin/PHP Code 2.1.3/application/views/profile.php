<!DOCTYPE html>
<html lang="en">
    <head>        
        <meta charset="UTF-8">
        <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Profile | <?php echo ($app_name) ? $app_name['message'] : "" ?></title>   

        <?php base_url() . include 'include.php'; ?>  
    </head>

    <body>
        <div id="app">
            <div class="main-wrapper">
                <?php base_url() . include 'header.php'; ?>  

                <!-- Main Content -->
                <div class="main-content">
                    <section class="section">
                        <div class="section-header">
                            <h1>Profile</h1>
                        </div>
                        <div class="section-body">
                            <div class="row">
                                <div class="col-12">
                                    <div class="card">
                                        <div class="card-body mt-4">
                                            <form method="post" class="needs-validation" novalidate=""  enctype="multipart/form-data">
                                                <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">
                                                <div class="form-group row">
                                                    <div class="col-md-6 col-sm-12">
                                                        <label class="control-label">Quiz Name</label>
                                                        <input name="app_name" type="text" value="<?php echo ($app_name) ? $app_name['message'] : "" ?>" required class="form-control" placeholder="Enter Quiz Name"/>
                                                    </div>
                                                    <div class="col-md-6 col-sm-12">
                                                        <label class="control-label">JWT KEY</label>
                                                        <input name="jwt_key" type="text" value="<?php echo ($jwt_key) ? $jwt_key['message'] : "" ?>" required class="form-control" placeholder="Enter JWT KEY"/>
                                                    </div>
                                                </div>
                                                <div class="form-group row">                                                   
                                                    <div class="col-md-6 col-sm-12">
                                                        <label class="control-label">Full Logo <small class="text-danger">(460 * 115 Size Allowed)</small></label>
                                                        <input id="full_file" name="full_file" type="file" accept="image/*" class="form-control">
                                                        <small class="text-danger">Image type supported (png, jpg ,jpeg and svg)</small>
                                                        <input type="hidden" name="full_url" value="<?= LOGO_IMG_PATH . $full_logo['message']; ?>">
                                                        <?php if (!empty($full_logo)) { ?>
                                                            <div class="m-2"><img src="<?= base_url() . LOGO_IMG_PATH . $full_logo['message']; ?>" alt="logo" width="250"></div>
                                                            <?php } ?>
                                                        <div style="display: none" id="msg_full_file" class="alert alert-danger"></div>
                                                    </div> 
                                                    <div class="col-md-6 col-sm-12">
                                                        <label class="control-label">Half Logo <small class="text-danger">(255 * 255 Size Allowed)</small></label>
                                                        <input id="half_file" name="half_file" type="file" accept="image/*" class="form-control">
                                                        <small class="text-danger">Image type supported (png, jpg ,jpeg and svg)</small>
                                                        <input type="hidden" name="half_url" value="<?= LOGO_IMG_PATH . $half_logo['message']; ?>">
                                                        <?php if (!empty($half_logo)) { ?>
                                                            <div class="m-2"><img src="<?= base_url() . LOGO_IMG_PATH . $half_logo['message']; ?>" alt="logo" height="60"></div>
                                                        <?php } ?>
                                                        <div style="display: none" id="msg_half_file" class="alert alert-danger"></div>
                                                    </div> 
                                                </div> 

                                                <div class="form-group row">
                                                    <div class="col-md-6 col-sm-12">
                                                        <label class="control-label">Login Background Image<small class="text-danger">(1920 * 1080 Recommended)</small></label>
                                                        <input id="background_file" name="background_file" type="file" accept="image/*" class="form-control">
                                                        <small class="text-danger">Image type supported (png, jpg and jpeg)</small>
                                                        <input type="hidden" name="background_file" value="<?= isset($background_file['message']) && !empty($background_file['message']) ? LOGO_IMG_PATH . $background_file['message'] : ""?>">
                                                        <div class="m-2"><img src="<?= isset($background_file['message']) && !empty($background_file['message']) ? base_url() . LOGO_IMG_PATH . $background_file['message'] : base_url() . LOGO_IMG_PATH .'background-image-stock.jpg'; ?>" alt="logo" width="150" height="80"></div>
                                                        <div style="display: none" id="msg_background_file" class="alert alert-danger"></div>
                                                    </div> 

                                                    <div class="col-md-6 col-sm-12">
                                                        <label class="control-label">Bot Image<small class="text-danger">(102 * 102 Recommended)</small></label>
                                                        <input id="bot_image" name="bot_image" type="file" accept="image/*" class="form-control">
                                                        <small class="text-danger">Image type supported (png, jpg and jpeg)</small>
                                                        <input type="hidden" name="bot_file" value="<?= isset($bot_image['message']) && !empty($bot_image['message']) ? LOGO_IMG_PATH . $bot_image['message']  : "" ?>">
                                                        <div class="m-2"><img src="<?= isset($bot_image['message']) && !empty($bot_image['message']) ? base_url() . LOGO_IMG_PATH . $bot_image['message'] : base_url() . LOGO_IMG_PATH .'bot-stock.png'; ?>" alt="logo" width="80" height="80"></div>
                                                        <div style="display: none" id="msg_bot_image" class="alert alert-danger"></div>
                                                    </div> 
                                                </div>

                                                <div class="form-group row">
                                                    <div class="col-sm-10">
                                                        <input type="submit" name="btnadd" value="Submit" class="<?= BUTTON_CLASS ?>"/>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </section>
                </div>
            </div>
        </div>

        <?php base_url() . include 'footer.php'; ?>

        <script type="text/javascript">
            var _URL = window.URL || window.webkitURL;

            $("#full_file").change(function (e) {
                var file, img;

                if ((file = this.files[0])) {
                    img = new Image();
                    img.onerror = function () {
                        $('#full_file').val('');
                        $('#msg_full_file').html('<?= INVALID_IMAGE_TYPE; ?>');
                        $('#msg_full_file').show().delay(3000).fadeOut();
                    };
                    img.src = _URL.createObjectURL(file);
                }
            });

            $("#half_file").change(function (e) {
                var file, img;

                if ((file = this.files[0])) {
                    img = new Image();
                    img.onerror = function () {
                        $('#half_file').val('');
                        $('#msg_half_file').html('<?= INVALID_IMAGE_TYPE; ?>');
                        $('#msg_half_file').show().delay(3000).fadeOut();
                    };
                    img.src = _URL.createObjectURL(file);
                }
            });


            $("#background_file").change(function (e) {
                var file, img;

                if ((file = this.files[0])) {
                    img = new Image();
                    img.onerror = function () {
                        $('#background_file').val('');
                        $('#msg_background_file').html('<?= INVALID_IMAGE_TYPE; ?>');
                        $('#msg_background_file').show().delay(3000).fadeOut();
                    };
                    img.src = _URL.createObjectURL(file);
                }
            });


            $("#bot_image").change(function (e) {
                var file, img;

                if ((file = this.files[0])) {
                    img = new Image();
                    img.onerror = function () {
                        $('#bot_image').val('');
                        $('#msg_bot_image').html('<?= INVALID_IMAGE_TYPE; ?>');
                        $('#msg_bot_image').show().delay(3000).fadeOut();
                    };
                    img.src = _URL.createObjectURL(file);
                }
            });
        </script>


    </body>
</html>