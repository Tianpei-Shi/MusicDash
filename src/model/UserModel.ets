/**
 * 用户数据JSON类型
 */
export interface UserJsonData {
  id: number;
  username: string;
  password: string;
  like?: string;
  history?: string;
  phone?: number;
  createdTime?: number;
  lastLoginTime?: number;
  avatar?: string;
}

/**
 * 用户信息模型 - 根据云数据库表结构定义
 */
export class UserInfo {
  id: number;
  username: string;
  password: string;
  like?: string;
  history?: string;
  phone?: number;
  createdTime?: number;
  lastLoginTime?: number;
  avatar?: string;

  constructor(id: number, username: string, password: string) {
    this.id = id;
    this.username = username;
    this.password = password;
    this.createdTime = Date.now();
    this.lastLoginTime = Date.now();
  }

  // 转换为CloudDB对象格式
  toCloudObject(): CloudDBZoneObject {
    const cloudObject: CloudDBZoneObject = {
      id: this.id,
      username: this.username,
      password: this.password,
      like: this.like || '',
      history: this.history || '',
      phone: this.phone || 0,
      createdTime: this.createdTime || Date.now(),
      lastLoginTime: this.lastLoginTime || Date.now(),
      avatar: this.avatar || ''
    };
    return cloudObject;
  }

  // 从CloudDB对象创建UserInfo
  static fromCloudObject(obj: CloudDBZoneObject): UserInfo {
    const user = new UserInfo(obj.id as number, obj.username as string, obj.password as string);
    user.like = obj.like as string;
    user.history = obj.history as string;
    user.phone = obj.phone as number;
    user.createdTime = obj.createdTime as number;
    user.lastLoginTime = obj.lastLoginTime as number;
    user.avatar = obj.avatar as string;
    return user;
  }

  /**
   * 从JSON对象创建UserInfo实例
   */
  static fromJson(json: UserJsonData): UserInfo {
    return new UserInfo(
      json.id,
      json.username,
      json.password
    );
  }

  /**
   * 转换为JSON对象
   */
  toJson(): UserJsonData {
    const data: UserJsonData = {
      id: this.id,
      username: this.username,
      password: this.password,
      like: this.like,
      history: this.history,
      phone: this.phone,
      createdTime: this.createdTime,
      lastLoginTime: this.lastLoginTime,
      avatar: this.avatar
    };
    return data;
  }
}

/**
 * 播放历史记录模型
 */
export class PlayHistory {
  id: string;
  userId: number;
  songId: number;
  songTitle: string;
  songArtist: string;
  playedTime: number;

  constructor(userId: number, songId: number, songTitle: string, songArtist: string) {
    this.id = `${userId}_${songId}_${Date.now()}`;
    this.userId = userId;
    this.songId = songId;
    this.songTitle = songTitle;
    this.songArtist = songArtist;
    this.playedTime = Date.now();
  }

  // 转换为CloudDB对象格式
  toCloudObject(): CloudDBZoneObject {
    const cloudObject: CloudDBZoneObject = {
      id: this.id,
      userId: this.userId,
      songId: this.songId,
      songTitle: this.songTitle,
      songArtist: this.songArtist,
      playedTime: this.playedTime
    };
    return cloudObject;
  }

  // 从CloudDB对象创建PlayHistory
  static fromCloudObject(obj: CloudDBZoneObject): PlayHistory {
    const history = new PlayHistory(
      obj.userId as number, 
      obj.songId as number, 
      obj.songTitle as string, 
      obj.songArtist as string
    );
    history.id = obj.id as string;
    history.playedTime = obj.playedTime as number;
    return history;
  }
}

/**
 * 云数据库对象接口
 * 使用显式类型定义代替索引签名
 */
export interface CloudDBZoneObject {
  id?: string | number;
  username?: string;
  password?: string;
  like?: string;
  history?: string;
  phone?: number;
  createdTime?: number;
  lastLoginTime?: number;
  avatar?: string;
  userId?: number;
  songId?: number;
  songTitle?: string;
  songArtist?: string;
  playedTime?: number;
}