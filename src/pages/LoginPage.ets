import prompt from '@ohos.promptAction';
import router from '@ohos.router';
import { UserService } from '../services/UserService';
import { UserInfo } from '../model/UserModel';

@Component
@Entry
export struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State isRegistering: boolean = false;
  @State registerUsername: string = '';
  @State registerPassword: string = '';
  @State registerConfirmPassword: string = '';
  private userService: UserService = UserService.getInstance();

  aboutToAppear() {
    // 初始化用户服务
    this.userService.initialize();
  }

  /**
   * 处理登录
   */
  async handleLogin(): Promise<void> {
    // 基本验证
    if (!this.username || !this.password) {
      prompt.showToast({
        message: '请输入用户名和密码'
      });
      return;
    }

    try {
      this.isLoading = true;
      // 调用登录服务
      await this.userService.login(this.username, this.password);
      prompt.showToast({
        message: '登录成功'
      });
      // 返回上一页
      router.back();
    } catch (error) {
      console.error('登录失败:', error);
      prompt.showToast({
        message: '登录失败：' + (error instanceof Error ? error.message : String(error))
      });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 处理注册
   */
  async handleRegister(): Promise<void> {
    // 基本验证
    if (!this.registerUsername || !this.registerPassword || !this.registerConfirmPassword) {
      prompt.showToast({
        message: '请输入所有必填信息'
      });
      return;
    }

    if (this.registerPassword !== this.registerConfirmPassword) {
      prompt.showToast({
        message: '两次输入的密码不一致'
      });
      return;
    }

    try {
      this.isLoading = true;
      // 创建用户信息
      const userInfo = new UserInfo(
        Date.now(), // 临时ID，将在保存时更新
        this.registerUsername,
        this.registerPassword
      );

      // 模拟注册服务
      await this.simulateRegister(userInfo);

      prompt.showToast({
        message: '注册成功，请登录'
      });

      // 切换回登录视图
      this.isRegistering = false;
      this.username = this.registerUsername;
      this.password = '';
      
      // 清空注册表单
      this.registerUsername = '';
      this.registerPassword = '';
      this.registerConfirmPassword = '';
    } catch (error) {
      console.error('注册失败:', error);
      prompt.showToast({
        message: '注册失败：' + (error instanceof Error ? error.message : String(error))
      });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 模拟注册过程
   */
  private async simulateRegister(userInfo: UserInfo): Promise<boolean> {
    // 这里模拟注册过程，因为原本的UserService中没有register方法
    await new Promise(resolve => setTimeout(resolve, 1000));
    return true;
  }

  /**
   * 切换到注册视图
   */
  switchToRegister(): void {
    this.isRegistering = true;
  }

  /**
   * 切换到登录视图
   */
  switchToLogin(): void {
    this.isRegistering = false;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')

      // 内容
      Column() {
        // 顶部导航
        Row() {
          Image($r('app.media.ic_play'))
            .width(24)
            .height(24)
            .onClick(() => router.back())
          
          Text(this.isRegistering ? '注册账号' : '登录账号')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          
          Blank()
            .width(24)
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .alignItems(VerticalAlign.Center)

        if (!this.isRegistering) {
          // 登录表单
          Column() {
            Image($r('app.media.ic_play'))
              .width(80)
              .height(80)
              .margin({ top: 40, bottom: 40 })
            
            // 用户名输入
            TextInput({ placeholder: '请输入用户名', text: this.username })
              .width('100%')
              .height(56)
              .margin({ bottom: 16 })
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .onChange((value) => {
                this.username = value;
              })
            
            // 密码输入
            TextInput({ placeholder: '请输入密码', text: this.password })
              .width('100%')
              .height(56)
              .type(InputType.Password)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .onChange((value) => {
                this.password = value;
              })
            
            // 登录按钮
            Button(this.isLoading ? '登录中...' : '登录')
              .width('100%')
              .height(50)
              .margin({ top: 32 })
              .enabled(!this.isLoading)
              .onClick(() => this.handleLogin())
            
            // 注册链接
            Row() {
              Text('没有账号？')
                .fontSize(14)
                .fontColor('#666666')
              
              Text('去注册')
                .fontSize(14)
                .fontColor('#007DFF')
                .onClick(() => this.switchToRegister())
            }
            .margin({ top: 16 })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .alignItems(HorizontalAlign.Center)
        } else {
          // 注册表单
          Column() {
            Image($r('app.media.ic_play'))
              .width(80)
              .height(80)
              .margin({ top: 40, bottom: 40 })
            
            // 用户名输入
            TextInput({ placeholder: '请输入用户名', text: this.registerUsername })
              .width('100%')
              .height(56)
              .margin({ bottom: 16 })
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .onChange((value) => {
                this.registerUsername = value;
              })
            
            // 密码输入
            TextInput({ placeholder: '请输入密码', text: this.registerPassword })
              .width('100%')
              .height(56)
              .margin({ bottom: 16 })
              .type(InputType.Password)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .onChange((value) => {
                this.registerPassword = value;
              })
            
            // 确认密码输入
            TextInput({ placeholder: '请确认密码', text: this.registerConfirmPassword })
              .width('100%')
              .height(56)
              .type(InputType.Password)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .onChange((value) => {
                this.registerConfirmPassword = value;
              })
            
            // 注册按钮
            Button(this.isLoading ? '注册中...' : '注册')
              .width('100%')
              .height(50)
              .margin({ top: 32 })
              .enabled(!this.isLoading)
              .onClick(() => this.handleRegister())
            
            // 登录链接
            Row() {
              Text('已有账号？')
                .fontSize(14)
                .fontColor('#666666')
              
              Text('去登录')
                .fontSize(14)
                .fontColor('#007DFF')
                .onClick(() => this.switchToLogin())
            }
            .margin({ top: 16 })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}