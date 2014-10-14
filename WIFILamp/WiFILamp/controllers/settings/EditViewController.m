//
//  EditViewController.m
//  WiFiLamp
//
//  Created by Aniapp on 14-2-13.
//
//

#import "EditViewController.h"
#import "MainCell.h"
#import "GlobalDefines.h"
#import "TBXML.h"
#import "Common.h"
#import "WaitingView.h"
#import "DispatchCenter+Data.h"

@interface EditViewController ()<LANTransmissionDelegate>
{
    WaitingView *_waitingView;
}

@property (nonatomic, retain) IBOutlet UITextField *nameTextField;

- (void)showWaitingView:(NSString*)text;
- (void)hideWaitingView;
- (void)syncLampName;
- (void)reloadSubViews;

@end

@implementation EditViewController

@synthesize nameTextField;

- (void)dealloc
{
    self.nameTextField = nil;
    [_waitingView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self syncLampName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods

- (void)showWaitingView:(NSString*)text
{
    if (_waitingView == nil)
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        _waitingView = [[WaitingView alloc] initWithFrame:rect];
    }
    
    [_waitingView show:self.navigationController.topViewController.view Text:text];
}

- (void)hideWaitingView
{
    [_waitingView hide];
}

- (void)reloadSubViews
{
    self.nameTextField.text = [Common defaultValueForKey:kXML_ATTR_NAME];
}

- (void)syncLampName
{
    [self showWaitingView:nil];
    [DispatchManager sendData:[NSData data] code:kCode_GetLampName userInfo:nil];
}

- (NSData*)lampName:(NSString*)name
{
    name = ([name length] <= 32) ? name : [name substringToIndex:32];
    NSString *str = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                     "<xml> <value code=\"%@\" /> </xml>", name];
    CLog(@"%@",str);
    return [NSData dataWithBytes:[str UTF8String] length:[str length]];
}

- (void)updateLampName:(NSString *)name
{
    [self showWaitingView:nil];
    [DispatchManager sendData:[self lampName:name] code:kCode_SetLampName userInfo:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self doneButtonPressed:nil];
    return YES;
}
- (UIStatusBarStyle)preferredStatusBarStyle

{
    
    return UIStatusBarStyleLightContent;
    
}
- (BOOL)prefersStatusBarHidden

{
    
    return NO;
    
}
#pragma mark - public methods

- (IBAction) backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed:(id)sender
{
    if ([self.nameTextField.text length] > 0)
    {
        [self.nameTextField resignFirstResponder];
        [self updateLampName:self.nameTextField.text];
    }
}

#pragma mark - LANTransmissionDelegate

- (void)processRecvData:(NSDictionary *)dict
{
    if ([dict count] > 0)
    {
        NSNumber *number = [[dict allKeys] objectAtIndex:0];
        NSInteger code = [number unsignedCharValue];
        NSData *data = [[dict allValues] objectAtIndex:0];
        
        if (data && ((code == kCode_GetLampName) || (code == kCode_SetLampName)))
        {
            [self hideWaitingView];
            
            NSError *error;
            TBXML *tbxml = [[TBXML alloc] initWithXMLData:data error:&error];
            if (tbxml && !error)
            {
                if (code == kCode_GetLampName)
                {
                    TBXMLElement *element = [TBXML childElementNamed:kXML_NODE_VALUE
                                                       parentElement:tbxml.rootXMLElement];
                    if (element)
                    {
                        NSString *info = [TBXML valueOfAttributeNamed:kXML_ATTR_CODE
                                                           forElement:element];
                        if (![info isEqualToString:kCODE_REQ_FAILED])
                        {
                            [Common setDefaultValueForKey:info Key:kXML_ATTR_NAME];
                            CLog(@"%ld, %@", (long)code, info);
                        }
                    }
                    [self reloadSubViews];
                }
                else if (code == kCode_SetLampName)
                {
                    TBXMLElement *element = [TBXML childElementNamed:kXML_NODE_VALUE
                                                       parentElement:tbxml.rootXMLElement];
                    if (element)
                    {
                        NSString *info = [TBXML valueOfAttributeNamed:kXML_ATTR_CODE
                                                           forElement:element];
                        if (![info isEqualToString:kCODE_REQ_FAILED])
                        {
                            [self syncLampName];
                            CLog(@"%ld, %@", (long)code, info);
                        }
                    }
                }
            }
            [tbxml release];
        }
    }
}

- (void)lanTransmission:(LANTransmission *)lanTransmission
               recvData:(NSDictionary *)dict
{
    [self performSelectorOnMainThread:@selector(processRecvData:)
                           withObject:dict waitUntilDone:NO];
}

- (void)lanTransmissionDisconnect:(LANTransmission *)lanTransmission
{
    [self performSelectorOnMainThread:@selector(hideWaitingView)
                           withObject:nil waitUntilDone:NO];
}

@end
