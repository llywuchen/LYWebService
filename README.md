# LYWebService
>
an weak coupling and convenient network request util based on AFNetworking.
could support auto Params and Data Parser,auto create reuqest.
also support flexible custom Parser settings... 

## Requirements
[AFNetworking](https://github.com/AFNetworking/AFNetworking)


### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

Then update dependents :

```bash
$ sh update.sh
```

## Usage

### configure LYWebClient

```objective-c
LYWebClientInstance.endPoint = [NSURL URLWithString:@"http://route.showapi.com"];
[LYWebClientInstance setPublicParams:[[LYPublicParamsDefault alloc] init]];
...    
```

#### Creating API

```objective-c
@protocol LYTextApi <LYWebService>

@GET("/967-1")
- (NSURLSessionDataTask*)getInfo:(NSString *)showapi_appid
                    suceessBlock:LY_SUCCESS_BLOCK(NSArray<LYTextModel *> *)callback
failBlock:LY_FAIL_BLOCK(NSString*)errorMessage;

@end
```

#### do task

```objective-c
[LYWebRequest(LYTextApi) getInfo:@"my_appSecret" suceessBlock:^(NSArray *result, NSURLResponse *response) {
        NSLog(@"LYWebRequest Suceess");
    } failBlock:^(NSString *errorMessage, NSURLResponse *response, NSError *error) {
        NSLog(@"LYWebRequest fail");
    }];

@end

```