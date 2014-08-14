//
//  Affiliation.h
//  AbstractManager
//
//  Created by Christian Kellner on 8/9/12.
//  Copyright (c) 2012 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract, Author, Organization;

@interface Affiliation : NSManagedObject

@property (nonatomic, retain) Abstract *forAbstract;
@property (nonatomic, retain) NSSet *ofAuthors;
@property (nonatomic, retain) Organization *toOrganization;
@end

@interface Affiliation (CoreDataGeneratedAccessors)

- (void)addOfAuthorsObject:(Author *)value;
- (void)removeOfAuthorsObject:(Author *)value;
- (void)addOfAuthors:(NSSet *)values;
- (void)removeOfAuthors:(NSSet *)values;

@end
