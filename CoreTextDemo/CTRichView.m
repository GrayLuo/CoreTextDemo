//
//  CTRichView.m
//  NetWorkProcessDemo
//
//  Created by hyq on 15/11/27.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import "CTRichView.h"

@implementation CTRichView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //step 1:
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //原点平移至左上角，并翻转Y轴
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    
    //step 2:
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    //step 3:
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"移动互联网实战之CoreText-Holder italicFont"];
    //设置字体
    UIFont *font = [UIFont systemFontOfSize:20];
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    [attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, 5)];
    
    
    //设置颜色
    UIColor *redColor = [UIColor redColor];
    CGColorRef colorRef = redColor.CGColor;
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)colorRef range:NSMakeRange(0, 7)];
    
    
    //下划线,
    NSMutableDictionary *attributeDic = [[NSMutableDictionary alloc]init];
    //下划线
    [attributeDic setObject:[NSNumber numberWithInt:kCTUnderlineStyleSingle] forKey:(id)kCTUnderlineStyleAttributeName];
    //下划线颜色
    [attributeDic setObject:[UIColor blueColor] forKey:(id)kCTUnderlineColorAttributeName];
    //字体
    UIFont *boldFont = [UIFont boldSystemFontOfSize:22];
    [attributeDic setObject:boldFont forKey:(id)kCTFontAttributeName];
    
    [attributedString addAttributes:attributeDic range:NSMakeRange(8, 15)];
    
    
    //斜体,
    CTFontRef italicFontRef = CTFontCreateWithName((CFStringRef)[UIFont italicSystemFontOfSize:20].fontName, 20, NULL);
    [attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFontRef range:NSMakeRange(attributedString.length-10, 10)];
    
    //图片
    CTRunDelegateCallbacks imageCallBacks;
    imageCallBacks.version = kCTRunDelegateCurrentVersion;
    imageCallBacks.dealloc = ImgRunDelegateDeallocCallback;
    imageCallBacks.getAscent = ImgRunDelegateGetAscentCallback;
    imageCallBacks.getDescent = ImgRunDelegateGetDescentCallback;
    imageCallBacks.getWidth = ImgRunDelegateGetWidthCallback;
    
    NSString *imgName = @"test.jpg";
    CTRunDelegateRef imgRunDelegate = CTRunDelegateCreate(&imageCallBacks, (__bridge void * _Nullable)(imgName));
    NSMutableAttributedString *imgAttributedStr = [[NSMutableAttributedString alloc]initWithString:@" "];
    [imgAttributedStr addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)imgRunDelegate range:NSMakeRange(0, 1)];
    CFRelease(imgRunDelegate);
    
    
#define kImgName @"imgName"
    
    [imgAttributedStr addAttribute:kImgName value:imgName range:NSMakeRange(0, 1)];
    
    [attributedString insertAttributedString:imgAttributedStr atIndex:30];
    
    
    //step 4:
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributedString length]), path, NULL);
    
    //step 5:
    CTFrameDraw(frame,context);
    
    //绘制图片
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);//获取第行的起始点
    for (int i = 0; i<CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;//上缘线
        CGFloat lineDescent;//下缘线
        CGFloat lineLeading;//行间距
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);//获取此行的字形参数
        
        //获取此行中每个CTRun
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for(int j = 0;j<CFArrayGetCount(runs);j++){
            CGFloat runAscent;//此CTRun上缘线
            CGFloat runDescent;//此CTRun下缘线
            CGPoint lineOrigin = lineOrigins[i];//此行起点
            
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);//获取此CTRun
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
            
            CGRect runRect;
            //获取此CTRun的上缘线，下缘线,并由此获取CTRun和宽度
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
            
            //CTRun的X坐标
            CGFloat runOrgX = lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runRect = CGRectMake(runOrgX,lineOrigin.y-runDescent,runRect.size.width,runAscent+runDescent );
            
            NSString *imgName = [attributes objectForKey:kImgName];
            if (imgName) {
                UIImage *image = [UIImage imageNamed:imgName];
                if(image){
                    CGRect imageRect ;
                    imageRect.size = image.size;
                    imageRect.origin.x = runRect.origin.x + lineOrigin.x;
                    imageRect.origin.y = lineOrigin.y;
                    CGContextDrawImage(context, imageRect, image.CGImage);
                }
            }
        }

    }

    //step 6:
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
}

#pragma mark - CTRunDelegateCallbacks
void ImgRunDelegateDeallocCallback( void* refCon ){
    CFRelease(refCon);
}


CGFloat ImgRunDelegateGetAscentCallback( void *refCon ){
    NSString *imageName = (__bridge NSString *)refCon;
    return [UIImage imageNamed:imageName].size.height;
}

CGFloat ImgRunDelegateGetDescentCallback(void *refCon){
    return 0;
}

CGFloat ImgRunDelegateGetWidthCallback(void *refCon){
    NSString *imageName = (__bridge NSString *)refCon;
    return [UIImage imageNamed:imageName].size.width;
}

@end
