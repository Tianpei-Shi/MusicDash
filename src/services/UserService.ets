// 暂时注释原始导入
// import agconnect from '@hw-agconnect/core';
// import auth from '@hw-agconnect/auth';
import { CloudDBService } from './CloudDBService';
import { UserInfo, PlayHistory, CloudDBZoneObject } from '../model/UserModel';
import { MusicItem } from '../model/MusicItem';

/**
 * 用户服务类
 * 包含用户登录、获取用户信息和播放历史等功能
 */
export class UserService {
  private static instance: UserService;
  private cloudDBService: CloudDBService;
  private currentUser: UserInfo | null = null;

  // 用户登录状态
  private loggedIn: boolean = false;

  // 获取单例实例
  static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  private constructor() {
    this.cloudDBService = CloudDBService.getInstance();
  }

  /**
   * 初始化用户服务
   */
  async initialize(): Promise<boolean> {
    try {
      // 初始化云数据库服务
      await this.cloudDBService.initialize();
      return true;
    } catch (error) {
      console.error('初始化用户服务失败:', error);
      return false;
    }
  }

  /**
   * 用户登录
   * @param username 用户名
   * @param password 密码
   */
  async login(username: string, password: string): Promise<UserInfo | null> {
    try {
      const userData = await this.cloudDBService.loginUser(username, password);
      if (userData) {
        this.currentUser = UserInfo.fromCloudObject(userData);
        this.loggedIn = true;
        return this.currentUser;
      }
      return null;
    } catch (error) {
      console.error('登录失败:', error);
      return null;
    }
  }

  /**
   * 获取当前用户
   */
  getCurrentUser(): UserInfo | null {
    return this.currentUser;
  }

  /**
   * 检查是否已登录
   */
  isLoggedIn(): boolean {
    return this.loggedIn;
  }

  /**
   * 登出
   */
  async signOut(): Promise<boolean> {
    this.currentUser = null;
    this.loggedIn = false;
    return true;
  }

  /**
   * 更新用户信息
   */
  async updateUserInfo(username: string, like?: string, phone?: number): Promise<boolean> {
    if (!this.currentUser) {
      return false;
    }
    
    this.currentUser.username = username;
    if (like) {
      this.currentUser.like = like;
    }
    if (phone) {
      this.currentUser.phone = phone;
    }
    
    return await this.cloudDBService.saveUserInfo(this.currentUser.toCloudObject());
  }

  /**
   * 保存播放历史
   */
  async savePlayHistory(song: MusicItem): Promise<boolean> {
    if (!this.currentUser) {
      return false;
    }
    
    // 获取当前历史记录
    const history = this.currentUser.history || '';
    
    // 添加新歌曲到历史记录
    if (history.length > 0) {
      // 检查是否已存在这首歌
      const songs = history.split(',');
      if (!songs.includes(song.title)) {
        // 如果不存在，添加到开头
        songs.unshift(song.title);
        // 仅保留最近10首
        while (songs.length > 10) {
          songs.pop();
        }
        this.currentUser.history = songs.join(',');
      }
    } else {
      // 如果历史为空，直接设置
      this.currentUser.history = song.title;
    }
    
    // 保存用户信息
    return await this.cloudDBService.saveUserInfo(this.currentUser.toCloudObject());
  }

  /**
   * 获取播放历史
   */
  async getPlayHistory(): Promise<PlayHistory[]> {
    if (!this.currentUser) {
      return [];
    }
    
    try {
      const historyData = await this.cloudDBService.getUserPlayHistory(this.currentUser.id);
      return historyData.map(data => PlayHistory.fromCloudObject(data));
    } catch (error) {
      console.error('获取播放历史失败:', error);
      return [];
    }
  }

  /**
   * 获取所有用户
   */
  async getAllUsers(): Promise<UserInfo[]> {
    try {
      const users = await this.cloudDBService.getAllUsers();
      return users.map(user => UserInfo.fromCloudObject(user));
    } catch (error) {
      console.error('获取所有用户失败:', error);
      return [];
    }
  }

  /**
   * 根据ID获取用户信息
   * @param userId 用户ID
   */
  async getUserById(userId: number): Promise<UserInfo | null> {
    try {
      const userData = await this.cloudDBService.getUserById(userId);
      if (userData) {
        return UserInfo.fromCloudObject(userData);
      }
      return null;
    } catch (error) {
      console.error('获取用户失败:', error);
      return null;
    }
  }

  /**
   * 保存用户信息
   * @param userInfo 用户信息
   */
  async saveUserInfo(userInfo: UserInfo): Promise<boolean> {
    try {
      const cloudObject = userInfo.toCloudObject();
      return await this.cloudDBService.saveUserInfo(cloudObject);
    } catch (error) {
      console.error('保存用户信息失败:', error);
      return false;
    }
  }

  /**
   * 获取用户播放历史
   * @param userId 用户ID
   */
  async getUserPlayHistory(userId: number): Promise<PlayHistory[]> {
    try {
      const historyData = await this.cloudDBService.getUserPlayHistory(userId);
      return historyData.map(data => PlayHistory.fromCloudObject(data));
    } catch (error) {
      console.error('获取播放历史失败:', error);
      return [];
    }
  }

  /**
   * 关闭服务
   */
  async close(): Promise<void> {
    await this.cloudDBService.close();
    this.currentUser = null;
  }
}