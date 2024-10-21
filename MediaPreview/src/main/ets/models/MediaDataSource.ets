export class MediaDataSource<T> implements IDataSource {
  private medias: T[] = []
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.medias.length
  }

  getData(index: number): T {
    return this.medias[index]
  }

  addData(index: number, ...data: T[]) {
    this.medias.splice(index, 0, ...data)
    this.notifyDataAdd(index)
  }

  pushData(...data: T[]) {
    this.medias.push(...data)
    this.notifyDataAdd(this.medias.length - 1)
  }

  deleteData(index: number) {
    this.medias.splice(index, 1)
    this.notifyDataDelete(index)
    this.notifyDataReload()
  }

  clear() {
    if (this.medias.length == 0) return
    this.medias.splice(0, this.medias.length)
    this.notifyDataReload()
  }

  changeData(index: number, data: T) {
    this.medias.splice(index, 1, data)
    this.notifyDataChange(index)
  }

  moveData(from: number, to: number) {
    let temp: T = this.medias[from]
    this.medias[from] = this.medias[to]
    this.medias[to] = temp
    this.notifyDataMove(from, to)
  }

  public reloadData(): void {
    this.notifyDataReload()
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  // 通知LazyForEach组件将from索引和to索引处的子组件进行交换
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}