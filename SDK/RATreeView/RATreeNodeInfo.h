
//The MIT License (MIT)
//
//Copyright (c) 2013 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

@class RATreeNodeInfo;
@interface RATreeNodeInfo : NSObject

@property (nonatomic, getter = isExpanded, readonly) BOOL expanded;
@property (nonatomic, readonly) NSInteger treeDepthLevel;       /**<树状展开的深度，层次级别*/

@property (nonatomic, readonly) NSInteger siblingsNumber;       /**<当前层中数量*/
@property (nonatomic, readonly) NSInteger positionInSiblings;   /**<每层中的位置*/

@property (strong, nonatomic, readonly) RATreeNodeInfo *parent;
@property (strong, nonatomic, readonly) NSArray *children;

@property (strong, nonatomic, readonly) id item;

@end
