//
//  Event.h
//  Visivent
//
//  Created by OLIVER HAGER on 12/20/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

#ifndef Event_h
#define Event_h

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Event : NSManagedObject
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Category * category;
@property (nonatomic, retain) DataSource * dataSource;
@end


#endif /* Event_h */
