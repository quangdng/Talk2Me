//
//  Helpers.m
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.
//

#import "Helpers.h"

BOOL FloatAlmostEqual(double x, double y, double delta) {
    return fabs(x - y) <= delta;
}

