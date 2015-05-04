/*
 *  EUExPluginName.m
 *  PluginDevelop
 *
 *  Note: This is to get photos from an album or camera development of plug-ins case.
 *  The development of other plug-ins, you need to modify the plugin class name and product name of the target.
 *  Modified, only need to replace "pluginname". On these.
 *
 *  Created by arbullzhang on 1-20-15.
 *  Copyright 2015 arbullzhang. All rights reserved.
 *
**/


/*
 
 1. 读取本插件的资源文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Resource/plugin_bg" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
 
 2. 读取协议路径资源文件 例如res://
    NSString *path = @"res://plugin_uexDemo_RES.png";
    path = [EUtility getAbsPath:self.meBrwView path:path];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
 
**/

#import "EUExPluginName.h"
#import "EUtility.h"
#import "EUExBaseDefine.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation EUExPluginName

-(id)initWithBrwView:(EBrowserView *) eInBrwView
{
	if(self = [super initWithBrwView:eInBrwView])
    {
	}
	return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(void)clean
{
}

// JS调用的方法， inArguments包含JS传回来的参数
-(void)open:(NSMutableArray *)inArguments
{
    [self selectPhoto];
}

- (void)selectPhoto
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:(id)self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"从相册中选取",@"拍照", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:(UIView *)meBrwView];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id)self;
    switch (buttonIndex)
    {
        case 0:
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [EUtility brwView:meBrwView presentModalViewController:picker animated:YES];
            }
        }
            break;
        case 1:
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [EUtility brwView:meBrwView presentModalViewController:picker animated:YES];
            }
            else
            {
                return;
            }
        }
            break;
        default:
            break;
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    switch (picker.sourceType)
    {
        case UIImagePickerControllerSourceTypePhotoLibrary:
        {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            [self returnPhotoAbsolutePath2JS:image];
        }
            break;
        case UIImagePickerControllerSourceTypeCamera:
        {
            UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
            if (image == nil)
                image = [info objectForKey:UIImagePickerControllerOriginalImage];
            [self returnPhotoAbsolutePath2JS:image];
        }
            break;
        default:
            break;
    }
}

- (void)returnPhotoAbsolutePath2JS:(UIImage *)photoImage;
{
    NSString *jpgPath = [NSString stringWithFormat:@"%@PluginName_%f.jpg", NSTemporaryDirectory(), CFAbsoluteTimeGetCurrent()];
    BOOL succeed = [UIImageJPEGRepresentation(photoImage, 1.0) writeToFile:jpgPath atomically:YES];
    if(succeed)
    {
        [self uexSuccessWithOpId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT data:jpgPath];
    }
    else
    {
        [self uexSuccessWithOpId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT data:nil];
    }
}

// 回调JS
-(void)uexSuccessWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString *)inData
{
    if (inData)
    {
        [self jsSuccessWithName:@"uexPluginName.returnPhotoPath" opId:inOpId dataType:inDataType strData:inData];
        //[self.meBrwView stringByEvaluatingJavaScriptFromString:@"uexPluginName.returnPhotoPath();"]; 调用JS的另外一种不传参数的方法
    }
}

@end