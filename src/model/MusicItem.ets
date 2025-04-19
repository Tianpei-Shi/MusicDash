/**
 * 音乐数据项模型
 */
export class MusicItem {
  id: number;
  title: string;
  artist: string;
  cover: string;
  duration: number; // 音乐时长(秒)
  url?: string; // 音乐文件地址

  constructor(id: number, title: string, artist: string, cover: string, duration: number, url?: string) {
    this.id = id;
    this.title = title;
    this.artist = artist;
    this.cover = cover;
    this.duration = duration;
    this.url = url;
  }

  /**
   * 格式化时长
   * @returns 格式化后的时长字符串 (mm:ss)
   */
  formatDuration(): string {
    const minutes = Math.floor(this.duration / 60);
    const seconds = this.duration % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }
}