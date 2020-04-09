//
//  NewOpuslib.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2020/1/15.
//  Copyright © 2020 zengqinglong. All rights reserved.
//

#import "NewOpuslib.h"

#include "libopus.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <opus/opus_types.h>

#define    REC_HOLE_BUF_NUM    (2)
#define HEAD_SIZE 44

unsigned char decoded_buffer[1280]= {0};

unsigned char encoded_buffer[640];

unsigned char tmp_buffer[102400] = {0};

@implementation NewOpuslib

- (NSData *)encodeWithPCM:(NSData *)data {
    *decoded_buffer = *(unsigned char *)data.bytes;
    NSData *newdata = [data subdataWithRange:NSMakeRange(0, 1280)];
    NSLog(@"data len = %ld", newdata.length);
    [self encodeBytes:(char *)newdata.bytes argc:data.length];
    return nil;
}

static void *ff_ict;

- (int)encodeBytes:(char *)argvs argc:(int)argc {
    FILE *fp_in = NULL;
    FILE *fp_out = NULL;
    int ret =-1;
    
    int mode =1;// default is wideband mode
    
    int output_len =6400;
    int encodeOnly = 0, decodeOnly =0, encodedecode =0;
    
    int bitrate = 16000;
    
    ret = OpusEncodeInit(&ff_ict,mode);
    if(ret != 0)
    {
        printf("init fail.\n");
        getchar();
        return -1;
    }
    printf("init success. \n");
//    while(1) {
//        output_len = 102400;
//        fread(argvs, sizeof(char), 1280, fp_in);
//        OpusEncode(ff_ict, argvs, argc, encoded_buffer, &output_len,bitrate);
//        memset(decoded_buffer, 0, sizeof(char)*1280);
//        if(output_len>0) {
//            fwrite(encoded_buffer, sizeof(char), output_len, fp_out);
//        }
//        if (feof(fp_in))
//            break;
//    }
    output_len = 640;
    ret = OpusEncode(ff_ict, argvs, argc, encoded_buffer, &output_len, bitrate);
    if (ret != 0) {
        NSLog(@"OpusEncode fail. %d", ret);
    }
    NSLog(@"de = %lu, en = %lu", sizeof(decoded_buffer), sizeof(encoded_buffer));
    ret =OpusEncodeFini(ff_ict);
    if(ret != 0)
    {
        printf("OpusEncodeFini fail. \n");
        getchar();
        return -1;
    }
    printf("OpusEncodeFini success. \n");
    fclose(fp_in);
    fclose(fp_out);
    return ret;
}

    

@end
