//
//  BridgeToDTMHeatmap.m
//  testpod
//
//  Created by OLIVER HAGER on 12/18/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "BridgeToDTMHeatmap.h"
#import "Visivent-Swift.h"
@implementation BridgeToDTMHeatmap

- (NSDictionary *)parseLatLonFile:(NSString *)fileName
{
    NSMutableDictionary *ret = [NSMutableDictionary new];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName
                                                     ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSArray *parts = [line componentsSeparatedByString:@","];
        NSString *latStr = parts[0];
        NSString *lonStr = parts[1];
        
        CLLocationDegrees latitude = [latStr doubleValue];
        CLLocationDegrees longitude = [lonStr doubleValue];
        
        // For this example, each location is weighted equally
        double weight = 1;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude
                                                          longitude:longitude];
        MKMapPoint point = MKMapPointForCoordinate(location.coordinate);
        NSValue *pointValue = [NSValue value:&point
                                withObjCType:@encode(MKMapPoint)];
        ret[pointValue] = @(weight);
    }
    
    return ret;
}

- (NSDictionary *)convertLatLonArray:(NSArray *) annotations
{
    NSMutableDictionary *ret = [NSMutableDictionary new];
    for (NSObject <MKAnnotation> *annotation in annotations) {
        // For this example, each location is weighted equally
        double weight = 1;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude
        longitude:annotation.coordinate.longitude];
        MKMapPoint point = MKMapPointForCoordinate(location.coordinate);
        NSValue *pointValue = [NSValue value:&point
                                withObjCType:@encode(MKMapPoint)];
        ret[pointValue] = @(weight);
    }
    return ret;
}

- (NSDictionary *)convertEventArray:(NSArray *) events
{
    NSMutableDictionary *ret = [NSMutableDictionary new];
    for (Event *event in events) {
        // For this example, each location is weighted equally
        double weight = 1;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:event.latitude
                                                          longitude:event.longitude];
        MKMapPoint point = MKMapPointForCoordinate(location.coordinate);
        NSValue *pointValue = [NSValue value:&point
                                withObjCType:@encode(MKMapPoint)];
        ret[pointValue] = @(weight);
    }
    return ret;
}

@end