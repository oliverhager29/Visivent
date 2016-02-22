//
//  MapCategory.h
//  Visivent
//
//  Created by OLIVER HAGER on 2/11/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

#ifndef MapCategory_h
#define MapCategory_h

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MapCategory : NSManagedObject
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * standardPinColor;
@property (nonatomic, retain) NSString * customizedIconFileName;
@end

#endif /* MapCategory_h */
