//
//  BridgeToDTMHeatmap.h
//  testpod
//
//  Created by OLIVER HAGER on 12/18/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@interface BridgeToDTMHeatmap : NSObject
- (NSDictionary *)parseLatLonFile:(NSString *)fileName;
- (NSDictionary *)convertLatLonArray:(NSArray *) array;
- (NSDictionary *)convertEventArray:(NSArray *) array;
@end
