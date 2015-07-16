//
//  BUKAssetsManager.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 7/15/15.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

@import AssetsLibrary;
#import "BUKAssetsManager.h"


@implementation BUKAssetsManager

#pragma mark - Class Methods

+ (instancetype)managerWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary {
    return [[self alloc] initWithAssetsLibrary:assetsLibrary];
}


#pragma mark - NSObject

- (instancetype)init {
    return [self initWithAssetsLibrary:[[ALAssetsLibrary alloc] init]];
}


- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary {
    if ((self = [super init])) {
        _assetsLibrary = assetsLibrary;
        _groupTypes = ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum | ALAssetsGroupPhotoStream;
        _mediaType = BUKImagePickerControllerMediaTypeAny;
    }
    return self;
}


- (instancetype)initWithAssetsLibrary:(ALAssetsLibrary *)assetsLibrary mediaTyle:(BUKImagePickerControllerMediaType)mediaType groupTypes:(ALAssetsGroupType)groupTypes {
    if ((self = [self initWithAssetsLibrary:assetsLibrary])) {
        _mediaType = mediaType;
        _groupTypes = groupTypes;
    }
    return self;
}


#pragma mark - Public

- (void)fetchAssetsGroupsWithCompletion:(void (^)(NSArray *))completion {
    return [self fetchAssetsGroupsWithGroupTypes:self.groupTypes mediaType:self.mediaType completion:completion];
}


- (void)fetchAssetsGroupsWithGroupTypes:(ALAssetsGroupType)groupTypes mediaType:(BUKImagePickerControllerMediaType)mediaType completion:(void (^)(NSArray *assetsGroups))completion {
    NSMutableArray *assetsGroups = [NSMutableArray array];
    ALAssetsFilter *assetsFilter = [self assetsFilterForMediaType:mediaType];
    
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        if (assetsGroup) {
            [assetsGroup setAssetsFilter:assetsFilter];
            [assetsGroups addObject:assetsGroup];
        }
        // When the enumeration is done, enumerationBlock is invoked with group set to nil.
        else {
            if (completion) {
                completion(assetsGroups);
            }
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"[BUKImagePickerController] An error occurs while fetching assets gourps: %@", [error localizedDescription]);
    }];
}


- (NSArray *)assetsInAssetsGroup:(ALAssetsGroup *)assetsGroup {
    NSMutableArray *mutableAssets = [NSMutableArray array];
    [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [mutableAssets addObject:result];
        }
    }];
    return mutableAssets;
}


#pragma mark - Private

- (ALAssetsFilter *)assetsFilter {
    return [self assetsFilterForMediaType:self.mediaType];
}


- (ALAssetsFilter *)assetsFilterForMediaType:(BUKImagePickerControllerMediaType)mediaType {
    switch (mediaType) {
        case BUKImagePickerControllerMediaTypeAny: {
            return [ALAssetsFilter allAssets];
        }
        case BUKImagePickerControllerMediaTypeImage: {
            return [ALAssetsFilter allPhotos];
        }
        case BUKImagePickerControllerMediaTypeVideo: {
            return [ALAssetsFilter allVideos];
        }
    }
}

@end