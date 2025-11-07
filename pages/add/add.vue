<template>
  <view class="container">
    <view>
      <input v-model="name" placeholder="姓名" />
      <input v-model="phone" placeholder="电话" />
      <input v-model="email" placeholder="邮箱" />
    </view>
    <button @click="addContact">保存</button>
  </view>
</template>

<script>
export default {
  data() {
    return {
      name: '',
      phone: '',
      email: ''
    }
  },
  methods: {
    async addContact() {
      await uni.request({
        url: 'http://localhost:3000/contacts',
        method: 'POST',
        data: {
          name: this.name,
          phone: this.phone,
          email: this.email
        }
      })
      uni.navigateBack()
    }
  }
}
</script>

<style>
.container { padding: 40rpx; }
input { display: block; margin: 20rpx 0; padding: 20rpx; border: 1px solid #ccc; border-radius: 8rpx; }
button { background-color: #4CAF50; color: white; padding: 20rpx; border-radius: 8rpx; }
</style>
