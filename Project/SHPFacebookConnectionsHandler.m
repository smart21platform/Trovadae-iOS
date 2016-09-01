//
//  SHPFacebookConnectionsHandler.m
//  Dressique
//
//  Created by andrea sponziello on 29/04/13.
//
//

#import "SHPFacebookConnectionsHandler.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SHPFacebookPage.h"

@implementation SHPFacebookConnectionsHandler

//@synthesize controllers;
//
//-(id)init {
//    self = [super init];
//    if (self) {
//        self.controllers = [[NSMutableArray alloc] init];
//    }
//    return self;
//}

+(void)publishProductWithDescription:(NSString *)productDescription image:(UIImage *)image onPage:(SHPFacebookPage *)page {
    NSLog(@"Building request to publish the story on page %@/%@", page.name, page.page_id);
    
//    NSLog(@"Printing current FBSession permissions:");
//    NSArray *permissions = [[FBSession activeSession] permissions];
//    for (NSString *permission in permissions) {
//        NSLog(@"-- %@", permission);
//    }
    if (page) {
        NSLog(@"page1");
        FBAccessTokenData* tokenData =
        [FBAccessTokenData createTokenFromString:page.accessToken
                                     permissions:@[@"publish_stream"]
                                  expirationDate:nil
                                       loginType:FBSessionLoginTypeFacebookApplication
                                     refreshDate:nil];
        
        [FBSession.activeSession closeAndClearTokenInformation];
        FBSession *session = [[FBSession alloc] init];
        [session openFromAccessTokenData:tokenData completionHandler: ^(FBSession *session,
                                                              FBSessionState status,
                                                              NSError *error) {
                                             NSLog(@"Session is now open. Error: %@", error);
//                                             [FBSession setActiveSession:session];
                                             [SHPFacebookConnectionsHandler sendStory:productDescription image:image withSession:session];
                                         }];
    }
    else {
        NSLog(@"on profile");
        if (!FBSession.activeSession.isOpen ||
        ![SHPFacebookConnectionsHandler sessionContainsPublishPermission:[FBSession activeSession]]) {
            NSLog(@"Opening new session.");
            [FBSession openActiveSessionWithPublishPermissions:[[NSArray alloc] initWithObjects:@"publish_stream", @"publish_actions", nil]
                                               defaultAudience:FBSessionDefaultAudienceFriends
                                                  allowLoginUI:YES
                                             completionHandler: ^(FBSession *session,
                                 FBSessionState status,
                                 NSError *error) {
                                                 NSLog(@"Session is now open. Error: %@", error);
                                                 [FBSession setActiveSession:session];
                                                 [SHPFacebookConnectionsHandler sendStory:productDescription image:image withSession:[FBSession activeSession]];
                                             }
             ];
        }
        else {
            NSLog(@"Session is open.");
            [SHPFacebookConnectionsHandler sendStory:productDescription image:image withSession:[FBSession activeSession]];
        }
    }
    
    // http://stackoverflow.com/questions/13831188/changing-defaultaudience-when-sharing-to-a-feed-using-facebook-ios-sdk
}

+(void)sendStory:(NSString *)productDescription image:(UIImage *)image withSession:(FBSession *)session {
    NSLog(@"New Request for publish with session token %@", session.accessTokenData.accessToken);
    FBRequest *req = [FBRequest requestForUploadPhoto:image];
    [req.parameters addEntriesFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:productDescription, @"message", nil]];
    //req.graphPath = @"me/friends";
    req.session = session; //[FBSession activeSession];
    //req.session = [FBSession activeSession];
    
    FBRequestConnection *con = [[FBRequestConnection alloc] init];
    [con
     addRequest:req
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         if (error) {
             NSLog(@"ERRORE REQUEST!!");
             NSLog(@"%@", error);
         } else {
             NSLog(@"Successfully published on Facebook with id %@", [result objectForKey:@"id"]);
         }
         // Show the result in an alert
         //         [[[UIAlertView alloc] initWithTitle:@"Result"
         //                                     message:alertText
         //                                    delegate:self
         //                           cancelButtonTitle:@"OK!"
         //                           otherButtonTitles:nil] show];
     }];
    [con start];
}

+(BOOL)sessionContainsPublishPermission:(FBSession *)session {
    NSArray *permissions = [[FBSession activeSession] permissions];
    
    NSString *string_to_find = @"publish_stream";
    BOOL stringFound = NO;
    for (NSString *string in permissions) {
        if ([string isEqualToString:string_to_find]) {
            stringFound = YES;
            NSLog(@"publish_stream permission found");
            break;
        }
    }
    
    if (!stringFound) {
        NSLog(@"publish_stream permission NOT found");
    }
    return stringFound;
}

//-(void)publishOnFacebook {
//    //    NSMutableDictionary *postParams =
//    //    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//    //     @"https://developers.facebook.com/ios", @"link",
//    //     @"https://developers.facebook.com/attachment/iossdk_logo.png", @"picture",
//    //     @"Facebook SDK for iOS", @"name",
//    //     @"Build great social apps and get more installs.", @"caption",
//    //     @"The Facebook SDK for iOS makes it easier and faster to develop Facebook integrated iOS apps.", @"description",
//    //     nil];
//    NSLog(@"Building request to publish the story");
//    
//    if (!FBSession.activeSession.isOpen) {
//        NSLog(@"Active session not open. Opening.");
//        [FBSession openActiveSessionWithAllowLoginUI: YES];
//    }
//    
//    FBRequest *req = [FBRequest requestForUploadPhoto:self.image];
//    [req.parameters addEntriesFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.descriptionTextView.text, @"message", nil]];
//    
//    FBRequestConnection *con = [[FBRequestConnection alloc] init];
//    [con
//     addRequest:req
//     completionHandler:^(FBRequestConnection *connection,
//                         id result,
//                         NSError *error) {
//         NSString *alertText;
//         if (error) {
//             alertText = [NSString stringWithFormat:
//                          @"error: domain = %@, code = %d",
//                          error.domain, error.code];
//             NSLog(@"%@", error);
//         } else {
//             alertText = [NSString stringWithFormat:
//                          @"Posted action, id: %@",
//                          [result objectForKey:@"id"]];
//         }
//         // Show the result in an alert
//         [[[UIAlertView alloc] initWithTitle:@"Result"
//                                     message:alertText
//                                    delegate:self
//                           cancelButtonTitle:@"OK!"
//                           otherButtonTitles:nil] show];
//     }];
//    [con start];
//    
//    //    [FBRequestConnection
//    //     startWithGraphPath:@"me/feed"
//    //     parameters:postParams
//    //     HTTPMethod:@"POST"
//    //     completionHandler:^(FBRequestConnection *connection,
//    //                         id result,
//    //                         NSError *error) {
//    //         NSString *alertText;
//    //         if (error) {
//    //             alertText = [NSString stringWithFormat:
//    //                          @"error: domain = %@, code = %d",
//    //                          error.domain, error.code];
//    //         } else {
//    //             alertText = [NSString stringWithFormat:
//    //                          @"Posted action, id: %@",
//    //                          [result objectForKey:@"id"]];
//    //         }
//    //         // Show the result in an alert
//    //         [[[UIAlertView alloc] initWithTitle:@"Result"
//    //                                     message:alertText
//    //                                    delegate:self
//    //                           cancelButtonTitle:@"OK!"
//    //                           otherButtonTitles:nil]
//    //          show];
//    //     }];
//}
//
//- (void)verifyPermissionAndPublishOnFacebook {
//    NSLog(@"Verifing facebook permissions to publish a photo...");
//    // Ask for publish_actions permissions in context
//    if ([FBSession.activeSession.permissions
//         indexOfObject:@"publish_actions"] == NSNotFound) {
//        NSLog(@"No permissions found in session, ask for it");
//        // No permissions found in session, ask for it
//        [FBSession.activeSession
//         requestNewPublishPermissions:
//         [[NSArray alloc] initWithObjects:@"publish_stream", @"user_photos", nil]
//         // @"publish_actions"
//         defaultAudience:FBSessionDefaultAudienceFriends
//         completionHandler:^(FBSession *session, NSError *error) {
//             if (!error) {
//                 // If permissions granted, publish the story
//                 NSLog(@"Permissions granted, publish the story");
//                 [self publishOnFacebook];
//             }
//         }];
//    } else {
//        // If permissions present, publish the story
//        NSLog(@"Permissions present, publish the story");
//        [self publishOnFacebook];
//    }
//}


@end
