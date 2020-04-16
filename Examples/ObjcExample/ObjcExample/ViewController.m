//  This file is part of an img.ly Software Development Kit.
//  Copyright (C) 2016-2020 img.ly GmbH <contact@img.ly>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

#import "ViewController.h"
@import CoreLocation;
@import PhotoEditorSDK;

@interface ViewController () <PESDKPhotoEditViewControllerDelegate>

@property (nonatomic, retain) PESDKTheme *theme;

@end

@implementation ViewController

@synthesize theme;

#pragma mark - UIViewController

- (void)viewDidLoad {
  if (@available(iOS 13.0, *)) {
    theme = PESDKTheme.dynamic;
  } else {
    theme = PESDKTheme.dark;
  }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    [self presentCameraViewController];
  } else if (indexPath.row == 1) {
    [self presentPhotoEditViewController];
  } else if (indexPath.row == 2) {
    theme = PESDKTheme.light;
    [self presentPhotoEditViewController];
    if (@available(iOS 13.0, *)) {
      theme = PESDKTheme.dynamic;
    } else {
      theme = PESDKTheme.dark;
    }
  } else if (indexPath.row == 3) {
    theme = PESDKTheme.dark;
    [self presentPhotoEditViewController];
    if (@available(iOS 13.0, *)) {
      theme = PESDKTheme.dynamic;
    } else {
      theme = PESDKTheme.dark;
    }
  } else if (indexPath.row == 4) {
    [self pushPhotoEditViewController];
  }
}

- (BOOL)prefersStatusBarHidden {
  // Before changing `prefersStatusBarHidden` please read the comment below
  // in `viewDidAppear`.
  return true;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  // This is a workaround for a bug in iOS 13 on devices without a notch
  // where pushing a `UIViewController` (with status bar hidden) from a
  // `UINavigationController` (status bar not hidden or vice versa) would
  // result in a gap above the navigation bar (on the `UIViewController`)
  // and a smaller navigation bar on the `UINavigationController`.
  //
  // This is the case when a `MediaEditViewController` is embedded into a
  // `UINavigationController` and uses a different `prefersStatusBarHidden`
  // setting as the parent view.
  //
  // Setting `prefersStatusBarHidden` to `false` would cause the navigation
  // bar to "jump" after the view appeared but this seems to be the only chance
  // to fix the layout.
  //
  // For reference see: https://forums.developer.apple.com/thread/121861#378841
  if (@available(iOS 13.0, *)) {
    [self.navigationController.view setNeedsLayout];
  }
}

#pragma mark - Configuration

- (PESDKConfiguration *)buildConfiguration {
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure camera
    [builder configureCameraViewController:^(PESDKCameraViewControllerOptionsBuilder * _Nonnull options) {
      // Just enable photos
      options.allowedRecordingModes = @[@(RecordingModePhoto)];
      // Show cancel button
      options.showCancelButton = true;
    }];

    // Configure editor
    [builder configurePhotoEditViewController:^(PESDKPhotoEditViewControllerOptionsBuilder * _Nonnull options) {
      NSMutableArray<PESDKPhotoEditMenuItem *> *menuItems = [[PESDKPhotoEditMenuItem defaultItems] mutableCopy];
      [menuItems removeLastObject]; // Remove last menu item ('Magic')
      options.menuItems = menuItems;
    }];

    // Configure sticker tool
    [builder configureStickerToolController:^(PESDKStickerToolControllerOptionsBuilder * _Nonnull options) {
      // Enable personal stickers
      options.personalStickersEnabled = true;
    }];

    // Configure theme
    builder.theme = self.theme;
  }];

  return configuration;
}

#pragma mark - Presentation

- (void)presentCameraViewController {
  PESDKConfiguration *configuration = [self buildConfiguration];
  PESDKCameraViewController *cameraViewController = [[PESDKCameraViewController alloc] initWithConfiguration:configuration];
  cameraViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  cameraViewController.locationAccessRequestClosure = ^(CLLocationManager * _Nonnull locationManager) {
    [locationManager requestWhenInUseAuthorization];
  };

  __weak PESDKCameraViewController *weakCameraViewController = cameraViewController;
  cameraViewController.cancelBlock = ^{
    [self dismissViewControllerAnimated:YES completion:nil];
  };
  cameraViewController.completionBlock = ^(UIImage * _Nullable image, NSURL * _Nullable url) {
    if (image != nil) {
      PESDKPhoto *photo = [[PESDKPhoto alloc] initWithImage:image];
      PESDKPhotoEditModel *photoEditModel = [weakCameraViewController photoEditModel];
      [weakCameraViewController presentViewController:[self createPhotoEditViewControllerWithPhoto:photo and:photoEditModel] animated:YES completion:nil];
    }
  };
  cameraViewController.dataCompletionBlock = ^(NSData * _Nullable data) {
    if (data != nil) {
      PESDKPhoto *photo = [[PESDKPhoto alloc] initWithData:data];
      PESDKPhotoEditModel *photoEditModel = [weakCameraViewController photoEditModel];
      [weakCameraViewController presentViewController:[self createPhotoEditViewControllerWithPhoto:photo and:photoEditModel] animated:YES completion:nil];
    }
  };

  [self presentViewController:cameraViewController animated:YES completion:nil];
}

- (PESDKPhotoEditViewController *)createPhotoEditViewControllerWithPhoto:(PESDKPhoto *)photo {
  return [self createPhotoEditViewControllerWithPhoto:photo and:[[PESDKPhotoEditModel alloc] init]];
}

- (PESDKPhotoEditViewController *)createPhotoEditViewControllerWithPhoto:(PESDKPhoto *)photo and:(PESDKPhotoEditModel *)photoEditModel {
  PESDKConfiguration *configuration = [self buildConfiguration];

  // Create a photo edit view controller
  PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:photo configuration:configuration photoEditModel:photoEditModel];
  photoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  photoEditViewController.delegate = self;

  return photoEditViewController;
}

- (void)presentPhotoEditViewController {
  NSURL *url = [[NSBundle mainBundle] URLForResource:@"LA" withExtension:@"jpg"];
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:url];
  [self presentViewController:[self createPhotoEditViewControllerWithPhoto:photo] animated:YES completion:nil];
}

- (void)pushPhotoEditViewController {
  NSURL *url = [[NSBundle mainBundle] URLForResource:@"LA" withExtension:@"jpg"];
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:url];
  [self.navigationController pushViewController:[self createPhotoEditViewControllerWithPhoto:photo] animated:YES];
}

#pragma mark - PhotoEditViewControllerDelegate

- (void)photoEditViewController:(PESDKPhotoEditViewController *)photoEditViewController didSaveImage:(UIImage *)image imageAsData:(NSData *)data {
  if (photoEditViewController.navigationController != nil) {
    [photoEditViewController.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)photoEditViewControllerDidFailToGeneratePhoto:(PESDKPhotoEditViewController *)photoEditViewController {
  if (photoEditViewController.navigationController != nil) {
    [photoEditViewController.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)photoEditViewControllerDidCancel:(PESDKPhotoEditViewController *)photoEditViewController {
  if (photoEditViewController.navigationController != nil) {
    [photoEditViewController.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

@end
