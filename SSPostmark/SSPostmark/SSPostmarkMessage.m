/*!
 * SSPostmarkMessage.m
 *
 * Copyright (c) 2014 OpenSky, LLC
 *
 * Created by Skylar Schipper on 7/16/14
 */

#import "SSPostmarkMessage.h"
#import "SSPostmarkHeaderItemPrivate.h"
#import "SSPostmarkMessageAttachmentPrivate.h"

@interface SSPostmarkMessage ()

@end

@implementation SSPostmarkMessage

- (instancetype)init {
    self = [super init];
    if (self) {
        self.trackOpens = YES;
    }
    return self;
}

- (BOOL)isValid {
    if (self.fromAddress.length == 0) {
        return NO;
    }
    if (!self.subject) {
        return NO;
    }
    if (!self.textBody && !self.HTMLBody) {
        return NO;
    }
    if (self.toAddresses.count == 0) {
        return NO;
    }
    return YES;
}


#pragma mark -
#pragma mark - Private
- (NSDictionary *)JSONRepresentation {
    NSMutableDictionary *JSON = [NSMutableDictionary dictionaryWithCapacity:10];
    
    JSON[@"From"] = self.fromAddress;
    JSON[@"Subject"] = self.subject;
    JSON[@"To"] = [self.class createEmailStringForSet:self.toAddresses];
    JSON[@"Cc"] = [self.class createEmailStringForSet:self.ccAddresses];
    JSON[@"Bcc"] = [self.class createEmailStringForSet:self.bccAddresses];
    JSON[@"Headers"] = [NSNull null];
    JSON[@"TrackOpens"] = @(self.trackOpens);
    
    if (self.HTMLBody) {
        JSON[@"HtmlBody"] = self.HTMLBody;
    }
    if (self.textBody) {
        JSON[@"TextBody"] = self.textBody;
    }
    if (self.tag) {
        JSON[@"Tag"] = self.tag;
    }
    if (self.replyToAddress) {
        JSON[@"ReplyTo"] = self.replyToAddress;
    }
    
    NSArray *headers = [self headerJSONArray];
    if (headers.count > 0) {
        JSON[@"Headers"] = headers;
    }
    
    NSArray *attachments = [self attachmentsJSONArray];
    if (attachments.count > 0) {
        JSON[@"Attachments"] = attachments;
    }
    
    return [JSON copy];
}

- (NSArray *)headerJSONArray {
    NSMutableArray *headers = [NSMutableArray new];
    for (SSPostmarkHeaderItem *headerItem in [self.additionalHeaders allObjects]) {
        [headers addObject:[headerItem JSONRepresentation]];
    }
    return [headers copy];
}
- (NSArray *)attachmentsJSONArray {
    NSMutableArray *attachments = [NSMutableArray new];
    for (SSPostmarkMessageAttachment *attachment in self.attachments) {
        [attachments addObject:[attachment JSONRepresentation]];
    }
    return [attachments copy];
}

+ (NSString *)createEmailStringForSet:(NSSet *)set {
    return [[[set allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] componentsJoinedByString:@", "];
}

@end
