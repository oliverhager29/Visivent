//
//  DataSource.h
//  Visivent
//
//  Created by OLIVER HAGER on 12/20/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

#ifndef DataSource_h
#define DataSource_h

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataSource : NSManagedObject
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@end

#endif /* DataSource_h */
