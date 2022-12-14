//
// Copyright (c) Alexey Nazarov, 2021
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "FunkObjC.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSArray (FunkObjC)

- (BOOL)FCT_PREFIX(hasEvery):(BOOL (^)(id item, NSUInteger idx))predicate {
    for (NSUInteger i = 0; i < self.count; ++i) {
        if (!predicate(self[i], i)) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)FCT_PREFIX(hasAny):(BOOL (^)(id item, NSUInteger idx))predicate {
    return [self FCT_PREFIX(first):predicate] != nil;
}

- (id _Nullable)FCT_PREFIX(first):(BOOL (^)(id item, NSUInteger idx))predicate {
    for (NSUInteger i = 0; i < self.count; ++i) {
        id item = self[i];
        if (predicate(item, i)) {
            return item;
        }
    }
    return nil;
}

- (instancetype)FCT_PREFIX(filter):(BOOL (^)(id item, NSUInteger idx))predicate {
    return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id item, NSUInteger idx, BOOL *stop) {
        return predicate(item, idx);
    }]];
}

- (instancetype)FCT_PREFIX(map):(id (^)(id item, NSUInteger idx))transform {
    if (self.FCT_PREFIX(isEmpty)) { return self.copy; }

    let arr = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
        [arr addObject:transform(item, idx) ?: NSNull.null];
    }];

    return arr.copy;
}

- (instancetype)FCT_PREFIX(compactMap):(id (^)(id item, NSUInteger idx))transform {
    if (self.FCT_PREFIX(isEmpty)) { return self.copy; }

    let arr = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
        id const next = transform(item, idx);
        if (next) {
            [arr addObject:next];
        }
    }];

    return arr.copy;
}

- (id _Nullable)FCT_PREFIX(reduce):(id _Nullable (^)(id _Nullable value, id next, NSUInteger idx))transform {
    return [self FCT_PREFIX(reduce):transform initial:nil];
}

- (id _Nullable)FCT_PREFIX(reduce):(id _Nullable (^)(id _Nullable value, id next, NSUInteger idx))transform initial:(id _Nullable)initial {
    id val = initial;
    for (NSUInteger i = 0; i < self.count; ++i) {
        val = transform(val, self[i], i);
    }
    return val;
}

- (instancetype)FCT_PREFIX(compact) {
    return [self FCT_PREFIX(filter):^BOOL(id item, NSUInteger idx) {
        return ![item isEqual:NSNull.null];
    }];
}

- (NSDictionary<id, id> *)FCT_PREFIX(dictionaryWithKeys):(id (^)(id value, NSUInteger idx))transform {
    return [NSDictionary dictionaryWithObjects:self forKeys:[self FCT_PREFIX(map):transform]];
}

- (NSDictionary<id, id> *)FCT_PREFIX(dictionaryWithValues):(id (^)(id key, NSUInteger idx))transform {
    return [NSDictionary dictionaryWithObjects:[self FCT_PREFIX(map):transform] forKeys:self];
}

- (BOOL)FCT_PREFIX(isEmpty) {
    return self.count == 0;
}

@end

@implementation NSSet (FunkObjC)

- (BOOL)FCT_PREFIX(hasEvery):(BOOL (^)(id item))predicate {
    for (id item in self) {
        if (!predicate(item)) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)FCT_PREFIX(hasAny):(BOOL (^)(id item))predicate {
    return [self FCT_PREFIX(first):predicate] != nil;
}

- (id _Nullable)FCT_PREFIX(first):(BOOL (^)(id item))predicate {
    for (id item in self) {
        if (predicate(item)) {
            return item;
        }
    }
    return nil;
}

- (instancetype)FCT_PREFIX(filter):(BOOL (^)(id item))predicate {
    return [self objectsPassingTest:^BOOL(id item, BOOL *stop) {
        return predicate(item);
    }];
}

- (instancetype)FCT_PREFIX(map):(id (^)(id item))transform {
    if (self.FCT_PREFIX(isEmpty)) { return self.copy; }

    let arr = [NSMutableSet setWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id item, BOOL *stop){
        [arr addObject:transform(item) ?: NSNull.null];
    }];

    return arr.copy;
}

- (instancetype)FCT_PREFIX(compactMap):(id (^)(id item))transform {
    if (self.FCT_PREFIX(isEmpty)) { return self.copy; }

    let set = [NSMutableSet setWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id item, BOOL *stop){
        id const next = transform(item);
        if (next) {
            [set addObject:next];
        }
    }];

    return set.copy;
}

- (id _Nullable)FCT_PREFIX(reduce):(id _Nullable (^)(id _Nullable value, id next))transform {
    return [self FCT_PREFIX(reduce):transform initial:nil];
}

- (id _Nullable)FCT_PREFIX(reduce):(id _Nullable (^)(id _Nullable value, id next))transform initial:(id _Nullable)initial {
    id val = initial;
    for (id item in self) {
        val = transform(val, item);
    }
    return val;
}

- (NSArray *)FCT_PREFIX(compact) {
    return [self FCT_PREFIX(filter):^BOOL(id item) {
        return ![item isEqual:NSNull.null];
    }];
}

- (BOOL)FCT_PREFIX(isEmpty) {
    return self.count == 0;
}

@end

@implementation NSDictionary (FunkObjC)

- (BOOL)FCT_PREFIX(hasEvery):(BOOL (^)(id, id))transform {
    if (transform) {
        for (id key in self.allKeys) {
            if (!transform(key, self[key])) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)FCT_PREFIX(hasAny):(BOOL (^)(id, id))transform {
    if (transform) {
        for (id key in self.allKeys) {
            if (transform(key, self[key])) {
                return YES;
            }
        }
    }
    return NO;
}

- (id)FCT_PREFIX(filter):(BOOL (^)(id key, id obj))predicate {
    let dict = [NSMutableDictionary dictionaryWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        if (predicate(key, obj)) {
            dict[key] = obj;
        }
    }];

    return dict.copy;
}

- (id)FCT_PREFIX(first):(BOOL (^)(id key, id obj))predicate {
    if (!predicate) { return nil; }
    return self[[self keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        return predicate(key, obj);
    }].anyObject];
}

- (id)FCT_PREFIX(compact) {
    let dict = [NSMutableDictionary dictionaryWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        if (![obj isEqual:NSNull.null]) {
            dict[key] = obj;
        }
    }];

    return dict.copy;
}

- (instancetype)FCT_PREFIX(mapObjects):(id (^)(id, id))transform {
    if (!transform) { return self; }

    let dict = [NSMutableDictionary dictionaryWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        dict[key] = transform(key, obj) ?: NSNull.null;
    }];

    return dict.copy;
}

- (instancetype)FCT_PREFIX(mapKeys):(id (^)(id, id))transform {
    if (!transform) { return self; }

    let dict = [NSMutableDictionary dictionaryWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        dict[transform(key, obj) ?: NSNull.null] = obj;
    }];

    return dict.copy;
}

- (id _Nullable)FCT_PREFIX(reduce):(id _Nullable (^)(id _Nullable value, id key, id obj))transform {
    return [self FCT_PREFIX(reduce):transform initial:nil];
}

- (id _Nullable)FCT_PREFIX(reduce):(id _Nullable (^)(id _Nullable value, id key, id obj))transform initial:(id _Nullable)initial {
    if (!transform) { return initial; }

    id val = initial;
    for (id key in self.allKeys) {
        val = transform(val, key, self[key]);
    }
    return val;
}

- (BOOL)FCT_PREFIX(isEmpty) {
    return self.count == 0;
}

@end

NSComparator FOBlockComparator(BOOL (^less)(id a, id b)) {
    return ^(id a, id b) {
        return less(a, b) ? NSOrderedAscending : (less(b, a) ? NSOrderedDescending : NSOrderedSame);
    };
}

NS_ASSUME_NONNULL_END
