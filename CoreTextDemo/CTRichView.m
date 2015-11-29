//
//  CTRichView.m
//  NetWorkProcessDemo
//
//  Created by hyq on 15/11/27.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import "CTRichView.h"

@implementation CTRichView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupEvents];
    }
    return self;
}
- (void)setupEvents{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userTapGestureDetected:)];
    
    [self addGestureRecognizer:tapRecognizer];
    
    self.userInteractionEnabled = YES;
}

- (void)userTapGestureDetected:(UIGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationInView:self];
    //先判断是否是点击的图片Rect
    for(CTImageData *imageData in _imageDataArray){
        CGRect imageRect = imageData.imageRect;
        CGFloat imageOriginY = self.bounds.size.height - imageRect.origin.y - imageRect.size.height;
        CGRect rect = CGRectMake(imageRect.origin.x,imageOriginY, imageRect.size.width, imageRect.size.height);
        if(CGRectContainsPoint(rect, point)){
            NSLog(@"tap image handle");
            return;
        }
    }
    
    //再判断链接
    CFIndex idx = [self touchPointOffset:point];
    if (idx != -1) {
        for(CTLinkData *linkData in _linkDataArray){
            if (NSLocationInRange(idx, linkData.range)) {
                NSLog(@"tap link handle,url:%@",linkData.url);
                break;
            }
        }
    }
}


- (CFIndex)touchPointOffset:(CGPoint)point{
    //获取所有行
    CFArrayRef lines = CTFrameGetLines(_ctFrame);
    
    if(lines == nil){
        return -1;
    }
    CFIndex count = CFArrayGetCount(lines);
    
    //获取每行起点
    CGPoint origins[count];
    CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), origins);
    
    
    //Flip
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CFIndex idx = -1;
    for (int i = 0; i<count; i++) {
        CGPoint lineOrigin = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        //获取每一行Rect
        CGFloat ascent = 0.0f;
        CGFloat descent = 0.0f;
        CGFloat leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGRect lineRect = CGRectMake(lineOrigin.x, lineOrigin.y - descent, width, ascent + descent);
        
        lineRect = CGRectApplyAffineTransform(lineRect, transform);
        
        if(CGRectContainsPoint(lineRect,point)){
            //将point相对于view的坐标转换为相对于该行的坐标
            CGPoint linePoint = CGPointMake(point.x-lineRect.origin.x, point.y-lineRect.origin.y);
            //根据当前行的坐标获取相对整个CoreText串的偏移
            idx = CTLineGetStringIndexForPosition(line, linePoint);
        }
    }
    return idx;
}



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
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"移动互联网实战之CoreText-Holder italicFont 颜值高，再丑的衣服都能穿出风韵来。中国中学校服是古往今来世界服装史上最丑也最反人性反人类的服饰之一，还不如文革时期的毛式衣服，仅次于从头裹到脚的burka。饶是这样的垃圾服装，也挡不住颜值逆袭"];
    //设置字体
    UIFont *font = [UIFont systemFontOfSize:20];
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    [attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, 5)];
    
    
    //设置颜色
    UIColor *redColor = [UIColor redColor];
    CGColorRef colorRef = redColor.CGColor;
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)colorRef range:NSMakeRange(0, 7)];
    
    
    //下划线,
    NSRange linkRange = NSMakeRange(8, 5);
    NSMutableDictionary *attributeDic = [[NSMutableDictionary alloc]init];
    //下划线
    [attributeDic setObject:[NSNumber numberWithInt:kCTUnderlineStyleSingle] forKey:(id)kCTUnderlineStyleAttributeName];
    //下划线颜色
    [attributeDic setObject:[UIColor blueColor] forKey:(id)kCTUnderlineColorAttributeName];
    //字体
    UIFont *boldFont = [UIFont boldSystemFontOfSize:22];
    [attributeDic setObject:boldFont forKey:(id)kCTFontAttributeName];
    
    [attributedString addAttributes:attributeDic range:linkRange];
    
    //
    if(!_linkDataArray){
        _linkDataArray = [[NSMutableArray alloc]init];
    }
    CTLinkData *ctLinkData = [[CTLinkData alloc]init];
    ctLinkData.text = [attributedString.string substringWithRange:linkRange];
    ctLinkData.url = @"http://www.baidu.com";
    ctLinkData.range = linkRange;
    [_linkDataArray addObject:ctLinkData];
    
    
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
    
    //底层由C实现的方法，其内存管理并不支持ARC，所以特别需要注意底层接口的内存管理。
    [self setCtFrame:frame];
    
    //step 5:
    CTFrameDraw(frame,context);
    
    //绘制图片
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);//获取第行的起始点
    
    NSInteger idx = -1;
    
    for (int i = 0; i<CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;//上缘线
        CGFloat lineDescent;//下缘线
        CGFloat lineLeading;//行间距
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);//获取此行的字形参数
        
        //获取此行中每个CTRun
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        idx += CFArrayGetCount(runs);
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
                    
                    //本演示示例，实战请在渲染之前处理数据，做到最佳实践
                    if(!_imageDataArray){
                        _imageDataArray = [[NSMutableArray alloc]init];
                    }
                    BOOL imgExist = NO;
                    for (CTImageData *ctImageData in _imageDataArray) {
                        if (ctImageData.idx == idx) {
                            imgExist = YES;
                            break;
                        }
                    }
                    if(!imgExist){
                        CTImageData *ctImageData = [[CTImageData alloc]init];
                        ctImageData.imgHolder = imgName;
                        ctImageData.imageRect = imageRect;
                        ctImageData.idx = idx;
                        [_imageDataArray addObject:ctImageData];
                    }
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
#pragma mark - Manage memory of CTFrame

- (void)setCtFrame:(CTFrameRef)ctFrame{
    if(_ctFrame != ctFrame){
        if(_ctFrame != nil){
            CFRelease(_ctFrame);
        }
        CFRetain(ctFrame);
        _ctFrame = ctFrame;
    }
}

- (void)dealloc{
    if(_ctFrame != nil){
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}



@end
