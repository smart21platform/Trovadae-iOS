//
//  SHPModifyProfileDC.m
//  TrovaDAE
//
//  Created by Dario De Pascalis on 01/07/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "SHPModifyProfileDC.h"
#import "SHPServiceUtil.h"
#import "SHPStringUtil.h"
#import "SHPUser.h"


@implementation SHPModifyProfileDC




- (void)updateUserPassword:(SHPUser *)user {
    NSLog(@"********************* update user psw ********************************** %@ - %@",user, self.nwPassword);
    self.serviceUrl = [SHPServiceUtil serviceUrl:@"service.uploaduserchangepassword"];
    NSLog(@"self.serviceUrl: %@", self.serviceUrl);
    [self callServiceForUpdateUser:user];
}


- (void)updateUserName:(SHPUser *)user {
    NSLog(@"********************* update user name ********************************** %@ - %@",user, user.email);
    self.serviceUrl = [SHPServiceUtil serviceUrl:@"service.updateuser"];
    NSLog(@"self.serviceUrl: %@", self.serviceUrl);
    [self callServiceForUpdateUser:user];
}

- (void)callServiceForUpdateUser:(SHPUser *)user {
    NSString *_url = self.serviceUrl;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    if (user) {
        NSLog(@"Operation with User %@", user.username);
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", user.httpBase64Auth];
        [request setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    } else {
        NSLog(@"Operation without User");
    }
    
    
    NSString *postString = [[NSString alloc] initWithFormat:@"fullName=%@&email=%@", [SHPStringUtil urlParamEncode:user.fullName], [SHPStringUtil urlParamEncode:user.email]];
    if(self.nwPassword && self.nwPassword.length>0){
        postString = [[NSString alloc] initWithFormat:@"old_password=%@&new_password=%@",self.oldPassword,self.nwPassword];
    }
    NSLog(@"POST Query: %@", postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.currentConnection = conn;
    if (conn) {
        self.receivedData = [[NSMutableData alloc] init];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        NSLog(@"Connection failed!");
    }
}

- (void)cancelConnection {
    [self.currentConnection cancel];
    self.currentConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    int code = (int)[(NSHTTPURLResponse*) response statusCode];
    self.statusCode = code;
    NSLog(@"didReceiveResponse statusCode! %ld \n %@", self.statusCode, response);
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error!");
    self.receivedData = nil;
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.delegate) {
        [self.delegate userUpdated:self error:error];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding]; //NSUTF8StringEncoding];
    NSLog(@"connectionDidFinishLoading statusCode! %ld", self.statusCode);
    if (self.statusCode >= 400 && self.statusCode <500) {
        NSLog(@"HTTP Error %ld", self.statusCode);
        NSString *code_s = [[NSString alloc] initWithFormat:@"%ld", self.statusCode];
        NSString *stringError = [NSString stringWithFormat:@"Error number %@",code_s];
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:stringError forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:self.serviceUrl code:self.statusCode userInfo:details];
        if (self.delegate) {
            [self.delegate userUpdated:self error:error];
        }
    }
    else{
        if (self.delegate) {
            [self.delegate userUpdated:self error:nil];
        }
    }
}


//----------------------------------------------//
//START FUNCTIONS JSONIZE
//----------------------------------------------//


-(NSDictionary *)jsonize:(NSDictionary *)properties {
    NSMutableDictionary *customPropertiesDict = [[NSMutableDictionary alloc] init];
    for (NSString *k in properties) {
        NSDictionary *propertyDictionary = [self customPropertyDictionary_name:k value:[properties objectForKey:k]];
        //[customPropertiesDict setObject:[self dictionary2JSON:propertyDictionary] forKey:k];
        [customPropertiesDict setObject:propertyDictionary forKey:k];
    }
    //return [self dictionary2JSON:customPropertiesDict];
    return customPropertiesDict;
}

-(NSDictionary *)customPropertyDictionary_name:(NSString *)propertyName value:(NSString *)propertyValue {
    NSArray *valuesProperty = @[propertyValue];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:propertyName forKey:@"_id"];
    [dict setValue:propertyName forKey:@"displayName"];
    [dict setValue:valuesProperty forKey:@"values"];
    return dict;
}

-(NSString *)dictionary2JSON:(NSDictionary *)dictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    //NSJSONWritingPrettyPrinted
    NSString *jsonString;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
//----------------------------------------------//
//END FUNCTIONS JSONIZE
//----------------------------------------------//
@end


