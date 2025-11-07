<template>
  <view class="app-container">
    <view class="header">
      <image src="/static/彩虹.png" class="icon" />
      <text class="title">🌈 联系人 💖</text>
      <image src="/static/彩虹独角兽.png" class="icon" />
    </view>

    <view class="add-section">
      <input v-model="newContact.name" placeholder="姓名" class="input" />
      <input v-model="newContact.phone" placeholder="电话" class="input" />
      <view class="avatar-upload">
        <image v-if="newContact.avatar" :src="newContact.avatar" class="avatar-preview" />
        <button @click="chooseAvatar" class="upload-btn">上传头像</button>
      </view>
      <button @click="addContact" class="add-btn">添加联系人</button>
    </view>

    <view class="contact-list">
      <view
        v-for="(contact, index) in sortedContacts"
        :key="index"
        class="contact-card"
      >
        <view class="contact-left">
          <image v-if="contact.avatar" :src="contact.avatar" class="avatar" />
          <view class="contact-info">
            <text class="contact-name">{{ contact.name }}</text>
            <text class="contact-phone">{{ contact.phone }}</text>
          </view>
        </view>
        <view class="contact-right">
          <button @click="togglePin(contact)" class="pin-btn">
            {{ contact.pinned ? "📌 取消置顶" : "📍 置顶" }}
          </button>
          <button @click="deleteContact(contact)" class="delete-btn">❌ 删除</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import axios from "axios";

export default {
  data() {
    return {
      contacts: [],
      newContact: {
        name: "",
        phone: "",
        avatar: "",
      },
    };
  },
  computed: {
    sortedContacts() {
      // 置顶优先 + 首字母排序
      return this.contacts
        .slice()
        .sort((a, b) => {
          if (a.pinned && !b.pinned) return -1;
          if (!a.pinned && b.pinned) return 1;
          return a.name.localeCompare(b.name, "zh");
        });
    },
  },
  methods: {
    async fetchContacts() {
      const res = await axios.get("http://localhost:3000/contacts");
      this.contacts = res.data;
    },
    async addContact() {
      if (!this.newContact.name || !this.newContact.phone) {
        return uni.showToast({ title: "请填写完整信息", icon: "none" });
      }
      await axios.post("http://localhost:3000/contacts", this.newContact);
      this.newContact = { name: "", phone: "", avatar: "" };
      this.fetchContacts();
    },
    async deleteContact(contact) {
      await axios.delete(`http://localhost:3000/contacts/${contact.id}`);
      this.fetchContacts();
    },
    async togglePin(contact) {
      contact.pinned = !contact.pinned;
      await axios.put(`http://localhost:3000/contacts/${contact.id}`, contact);
      this.fetchContacts();
    },
    chooseAvatar() {
      uni.chooseImage({
        count: 1,
        success: async (res) => {
          const filePath = res.tempFilePaths[0];
          const uploadRes = await uni.uploadFile({
            url: "http://localhost:3000/upload",
            filePath,
            name: "avatar",
          });
          const data = JSON.parse(uploadRes.data);
          this.newContact.avatar = data.url;
        },
      });
    },
  },
  mounted() {
    this.fetchContacts();
  },
};
</script>

<style>
.app-container {
  background: linear-gradient(to bottom right, #ffe6f2, #e6ccff);
  min-height: 100vh;
  padding: 20rpx;
  font-family: "Comic Sans MS", cursive;
}

.header {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 30rpx;
}

.icon {
  width: 60rpx;
  height: 60rpx;
  margin: 0 10rpx;
}

.title {
  font-size: 48rpx;
  color: #cc66ff;
  font-weight: bold;
  text-shadow: 2rpx 2rpx #ff99cc;
}

.add-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  background: #fff0fa;
  border-radius: 20rpx;
  padding: 20rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.1);
  margin-bottom: 20rpx;
}

.input {
  width: 80%;
  margin: 10rpx 0;
  border: 2rpx solid #ffb3ec;
  border-radius: 10rpx;
  padding: 10rpx;
}

.upload-btn {
  background: #d9b3ff;
  color: white;
  padding: 10rpx 20rpx;
  border-radius: 10rpx;
  margin-top: 10rpx;
}

.avatar-preview {
  width: 100rpx;
  height: 100rpx;
  border-radius: 50%;
  margin-bottom: 10rpx;
}

.add-btn {
  background: #ff99cc;
  color: white;
  margin-top: 10rpx;
  padding: 10rpx 40rpx;
  border-radius: 20rpx;
}

.contact-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #ffffffaa;
  border-radius: 20rpx;
  margin: 10rpx 0;
  padding: 20rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
}

.contact-left {
  display: flex;
  align-items: center;
}

.avatar {
  width: 100rpx;
  height: 100rpx;
  border-radius: 50%;
  margin-right: 20rpx;
  border: 3rpx solid #ffb3ec;
}

.contact-info {
  display: flex;
  flex-direction: column;
}

.contact-name {
  font-size: 36rpx;
  color: #cc66ff;
}

.contact-phone {
  font-size: 28rpx;
  color: #666;
}

.pin-btn,
.delete-btn {
  background: #e6ccff;
  border-radius: 10rpx;
  padding: 10rpx 20rpx;
  margin-left: 10rpx;
}

.delete-btn {
  background: #ffcccc;
}
</style>
