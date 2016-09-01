/*
    NSManagedObjectID.h
    Core Data
    Copyright (c) 2004-2012 Apple Inc.
    All rights reserved.
*/

#import <Foundation/NSObject.h>

@class NSPersistentStore;
@class NSEntityDescription;
@class NSURL;

// Managed object IDs are opaque identifiers for managed objects.
NS_CLASS_AVAILABLE(10_4,3_0)
@interface NSManagedObjectID : NSObject <NSCopying> {
}

@property (readonly, strong) NSEntityDescription *entity;    // entity for the object identified by an ID
@property (readonly, weak) NSPersistentStore *persistentStore;    // persistent store that fetched the object identified by an ID

@property (getter=isTemporaryID, readonly) BOOL temporaryID;    // indicates whether or not this ID will be replaced later, such as after a save operation (temporary IDs are assigned to newly inserted objects and replaced with permanent IDs when an object is written to a persistent store); most IDs return NO

- (NSURL *)URIRepresentation;    // URI which provides an archivable reference to the object which this ID refers

@end
