import prompt from '@ohos.promptAction';
import router from '@ohos.router';
import { UserService } from '../../services/UserService';
import { UserInfo } from '../../model/UserModel';

@Component
export struct ProfilePage {
  @State isLoggedIn: boolean = false;
  @State isLoading: boolean = false;
  @State userInfo: UserInfo = new UserInfo(0, '游客', '');
  private userService: UserService = UserService.getInstance();

  aboutToAppear() {
    this.isLoading = true;
    this.checkLoginStatus();
  }

  /**
   * 检查登录状态并获取用户信息
   */
  async checkLoginStatus() {
    try {
      // 初始化用户服务
      await this.userService.initialize();
      
      // 检查登录状态
      this.isLoggedIn = this.userService.isLoggedIn();
      
      if (this.isLoggedIn) {
        const currentUser = this.userService.getCurrentUser();
        if (currentUser) {
          this.userInfo = currentUser;
        }
      }
    } catch (error) {
      console.error('获取用户信息失败:', error);
      prompt.showToast({
        message: '获取用户信息失败'
      });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 格式化时间
   */
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
  }

  /**
   * 跳转到用户中心
   */
  gotoUserProfile(): void {
    if (!this.isLoggedIn) {
      // 未登录，跳转到登录页面
      router.pushUrl({
        url: 'pages/LoginPage'
      });
    } else {
      // 已登录，跳转到用户详情页
      router.pushUrl({
        url: 'pages/user/UserDetailPage',
        params: {
          userId: this.userInfo.id
        }
      });
    }
  }

  /**
   * 跳转到播放历史页面
   */
  gotoPlayHistory(): void {
    if (!this.isLoggedIn) {
      prompt.showToast({
        message: '请先登录'
      });
      return;
    }
    
    router.pushUrl({
      url: 'pages/music/PlayHistoryPage',
      params: {
        userId: this.userInfo.id
      }
    });
  }

  /**
   * 退出登录
   */
  async logout(): Promise<void> {
    try {
      this.isLoading = true;
      await this.userService.signOut();
      this.isLoggedIn = false;
      this.userInfo = new UserInfo(0, '游客', '');
      prompt.showToast({ message: '已退出登录' });
    } catch (error) {
      console.error('退出登录失败:', error);
      prompt.showToast({ message: '退出登录失败' });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部用户信息
      Row() {
        if (this.isLoading) {
          LoadingProgress()
            .width(32)
            .height(32)
            .margin(20)
        } else if (this.isLoggedIn) {
          Row() {
            // 用户头像
            Image(this.userInfo.avatar || $r('app.media.ic_play'))
              .width(70)
              .height(70)
              .borderRadius(35)
              .backgroundColor('#EFEFEF')
            
            // 用户信息
            Column() {
              Text(this.userInfo.username)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
              
              Text(`ID: ${this.userInfo.id.toString().substring(0, 6)}...`)
                .fontSize(12)
                .opacity(0.6)
                .margin({ top: 4 })
              
              Text(`注册时间: ${this.formatDate(this.userInfo.createdTime)}`)
                .fontSize(12)
                .opacity(0.6)
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 16 })
            .layoutWeight(1)
            
            // 右侧进入用户中心箭头
            Image($r('app.media.ic_play'))
              .width(24)
              .height(24)
              .margin({ right: 8 })
          }
          .width('100%')
          .height(100)
          .padding({ left: 20, right: 20 })
          .onClick(() => this.gotoUserProfile())
        } else {
          // 未登录状态
          Column() {
            Text('登录账号')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            
            Text('登录后享受更多功能')
              .fontSize(14)
              .opacity(0.6)
              .margin({ top: 8 })
            
            Button('登录 / 注册')
              .width(120)
              .height(36)
              .margin({ top: 12 })
              .onClick(() => this.gotoUserProfile())
          }
          .alignItems(HorizontalAlign.Start)
          .padding(20)
        }
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius({ bottomLeft: 20, bottomRight: 20 })
      .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 5 })
      
      // 菜单选项
      Column() {
        // 我的播放历史
        MenuItemView({
          icon: $r('app.media.ic_play'),
          title: '播放历史',
          onItemClick: (): void => this.gotoPlayHistory()
        })
        
        // 我喜欢的音乐
        MenuItemView({
          icon: $r('app.media.ic_play'),
          title: '我喜欢的音乐'
        })
        
        // 我的收藏
        MenuItemView({
          icon: $r('app.media.ic_play'),
          title: '我的收藏'
        })
        
        // 本地音乐
        MenuItemView({
          icon: $r('app.media.ic_play'),
          title: '本地音乐'
        })
        
        // 最近播放
        MenuItemView({
          icon: $r('app.media.ic_play'),
          title: '最近播放'
        })
        
        // 我的云盘
        MenuItemView({
          icon: $r('app.media.ic_play'),
          title: '我的云盘'
        })
        
        // 我的电台
        MenuItemView({
          icon: $r('app.media.ic_play'),
          title: '我的电台'
        })
      }
      .width('100%')
      .margin({ top: 20 })
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .padding({ top: 10, bottom: 10 })
      
      // 设置区域
      Column() {
        MenuItemView({
          icon: $r('app.media.ic_play'),
          title: '设置'
        })
        
        MenuItemView({
          icon: $r('app.media.ic_play'),
          title: '关于'
        })
        
        if (this.isLoggedIn) {
          MenuItemView({
            icon: $r('app.media.ic_play'),
            title: '退出登录',
            titleColor: '#FF4081',
            onItemClick: () => {
              this.logout();
            }
          })
        }
      }
      .width('100%')
      .margin({ top: 20, bottom: 20 })
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .padding({ top: 10, bottom: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .padding({ left: 16, right: 16, bottom: 16 })
  }
}

@Component
struct MenuItemView {
  icon: Resource = $r('app.media.ic_play');
  title: string = '';
  titleColor?: string = '#333333';
  onItemClick?: () => void = () => {};

  build() {
    Row() {
      Image(this.icon)
        .width(24)
        .height(24)
      
      Text(this.title)
        .fontSize(16)
        .fontColor(this.titleColor)
        .margin({ left: 12 })
        .layoutWeight(1)
      
      Image($r('app.media.ic_play'))
        .width(16)
        .height(16)
        .opacity(0.6)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick();
      }
    })
  }
}