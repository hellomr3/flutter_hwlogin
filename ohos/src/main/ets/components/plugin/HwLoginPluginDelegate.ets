import { MethodCall, MethodResult } from "@ohos/flutter_ohos";
import authentication from '@hms.core.authentication';
import { BusinessError } from "@ohos.base";
import { Ability } from "@kit.AbilityKit";
import { loginComponentManager } from "@kit.AccountKit";
import { ErrorCode } from "./ErrorCode";
import { LoginInfo } from "./LoginInfo";
import util from "@ohos.util";
import hilog from "@ohos.hilog";

export class HwLoginPluginDelegate {
  ability: Ability | null = null

  handleMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      // 获取当前手机号
      case "getPhone":
        this.getPhone(call, result)
        break;
      case "login":
        this.login(call, result)
        break;
      default:
        result.notImplemented()
        break;
    }
  }

  cancel() {
    // doNothing
  }

  async getPhone(call: MethodCall, result: MethodResult) {
    // 创建授权请求
    let authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 应用请求的用户信息
    authRequest.scopes = ['quickLoginAnonymousPhone', 'openid'];
    // 一键登录场景下，forceAuthorization必须传false
    authRequest.forceAuthorization = false;
    let controller = new authentication.AuthenticationController();
    try {
      controller.executeRequest(authRequest).then((response: authentication.AuthorizationWithHuaweiIDResponse) => {
        // 获取到UnionID、匿名手机号，推荐开发者使用UnionID作为关联信息
        let unionID = response.data?.unionID;
        let quickLoginAnonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        result.success(quickLoginAnonymousPhone)
      }).catch((error: BusinessError) => {
        result.error(error.code.toString(), error.message, error);
      })
    } catch (error) {
      result.error(error.code.toString(), error.message, error);
    }
  }

  async login(call: MethodCall, result: MethodResult) {
    // 创建登录请求，并设置参数
    const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    // 用户是否需要登录授权，该值为true且用户未登录或未授权时，会拉起用户登录或授权页面
    loginRequest.forceLogin = true;
    // 用于防跨站点请求伪造
    loginRequest.state = util.generateRandomUUID();
    // 执行登录请求
    try {

      const controller = new authentication.AuthenticationController(getContext());
      controller.executeRequest(loginRequest).then((response: authentication.LoginWithHuaweiIDResponse) => {
        const loginWithHuaweiIDResponse = response as authentication.LoginWithHuaweiIDResponse;
        const state = loginWithHuaweiIDResponse.state;
        if (state && loginRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to login. The state is different, response state: ${state}`);
          return;
        }
        const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse?.data;
        const code = loginWithHuaweiIDCredential?.authorizationCode;
        const idToken = loginWithHuaweiIDCredential?.idToken;
        // 开发者处理code, idToken
        result.success(code);
      }).catch((error: BusinessError) => {
        if (error.code === ErrorCode.ERROR_CODE_NETWORK_ERROR) {
          result.error(error.code.toString(), "网络未连接", error)
        } else if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
          result.error(error.code.toString(), "未同意协议", error)
        } else if (error.code === ErrorCode.ERROR_CODE_LOGIN_OUT) {
          // 提示华为账号未登录
          result.error(error.code.toString(), "华为账号未登录", error)
        } else if (error.code === ErrorCode.ERROR_CODE_NOT_SUPPORTED) {
          // 不支持该scopes或permissions提示
          result.error(error.code.toString(), "不支持该scopes或permissions提示", error)
        } else {
          // 当前提示系统或服务异常，可根据实际情况处理
          result.error(error.code.toString(), "当前提示系统或服务异常", error)
        }
      })
    } catch (error) {
      result.error(error.code.toString(), "登录失败", error)
    }
  }
}