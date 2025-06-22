<script setup lang="ts">
const localePath = useLocalePath()
const { locale, setLocale } = useI18n()
const selectedLocale = ref('')
const colorMode = useColorMode()
const isBgBlur = ref(false)
const userInfo = useUserInfo()
const tmpNickname = ref('')
const userInfoPopover = ref()
const i18nPopover = ref()
const isConfirmDefault = useConfirmDefault()
const availableLocales = ref([
  { name: 'English', code: 'en', icon: 'icon-park-outline:english' },
  { name: '中文', code: 'zh', icon: 'icon-park-outline:chinese' }
])

// 暗色模式切换
function switchColorMode() {
  if (colorMode.preference === 'light') {
    colorMode.preference = 'dark'
  } else {
    colorMode.preference = 'light'
  }
}

// 中英语言切换
function switchI18n() {
  if (locale.value === 'en') {
    setLocale('zh')
  } else {
    setLocale('en')
  }
}

// 是否开启发送方自动确认
function switchConfirmDefault() {
  localStorage.setItem('isConfirmDefault', JSON.stringify(isConfirmDefault.value))
}

// 展示昵称编辑弹框
function showNicknameEditor(event: Event) {
  tmpNickname.value = userInfo.value.nickname
  userInfoPopover.value.toggle(event)
}

// 编辑昵称
function editNickname() {
  userInfo.value.nickname = tmpNickname.value.trim().substring(0, 16)
  if (!userInfo.value.nickname) {
    userInfo.value.nickname = 'User_' + genRandomString(6)
  }
  localStorage.setItem('nickname', userInfo.value.nickname)
  userInfoPopover.value.hide()
}

// 编辑头像
function editAvatar() {
  selectAvatar((url) => {
    if (url) {
      userInfo.value.avatarURL = url
      localStorage.setItem('avatarURL', url)
    }
  })
}

// 重置用户信息
function clearUserInfo() {
  initAvatar()
  userInfo.value.nickname = 'User_' + genRandomString(6)
  tmpNickname.value = userInfo.value.nickname
  localStorage.setItem('nickname', userInfo.value.nickname)
}

function initAvatar() {
  const fr = new FileReader()
  fr.onload = () => {
    userInfo.value.avatarURL = fr.result + ''
    localStorage.setItem('avatarURL', userInfo.value.avatarURL)
  }
  fetch('/akari.webp')
    .then((res) => res.blob())
    .then((blob) => fr.readAsDataURL(blob))
}

onMounted(() => {
  window.addEventListener('scroll', () => {
    isBgBlur.value = getScrollTop() > 64
  })

  // 初始化昵称
  let nickname = localStorage.getItem('nickname')
  if (!nickname) {
    nickname = 'User_' + genRandomString(6)
    localStorage.setItem('nickname', nickname)
  }
  userInfo.value.nickname = nickname

  // 初始化头像
  const avatarURL = localStorage.getItem('avatarURL')
  if (!avatarURL) {
    initAvatar()
  } else {
    userInfo.value.avatarURL = avatarURL
  }

  // 初始化配置
  if (getValFromLocalStorage('isConfirmDefault', false)) {
    isConfirmDefault.value = true
  }
})
</script>

<template>
  <nav
    class="flex flex-row items-center py-3 px-4 md:py-4 md:px-[10vw] sticky left-0 right-0 top-0 z-50 nav-bar"
    :class="{ 'backdrop-blur': isBgBlur }"
  >
    <NuxtLink :to="localePath('/')">
      <div class="tracking-wider">
        <img src="/favicon.webp" class="inline-block size-[32px] mr-1" />LiuShen Send
      </div>
    </NuxtLink>

    <div class="flex-1"></div>

    <div class="contents text-sm">
      <Avatar
        :image="userInfo.avatarURL"
        shape="circle"
        class="shadow cursor-pointer"
        @click="showNicknameEditor"
      />
      <p class="ml-2 truncate shrink-[1000] hidden md:block">
        {{ userInfo.nickname }}
      </p>
    </div>

    <!-- 用户信息弹出框 -->
    <Popover ref="userInfoPopover">
      <div class="relative p-3 m-2">
        <div class="absolute top-0 right-0 z-10">
          <Button
            severity="secondary"
            text
            @click="clearUserInfo"
            size="small"
            class="py-3"
            aria-label="Language"
          >
            <Icon name="material-symbols:sync-rounded" class="text-rose-500 dark:text-rose-600" />
          </Button>
        </div>

        <div class="relative flex flex-col items-center gap-4">
          <Avatar
            :image="userInfo.avatarURL"
            shape="circle"
            class="shadow-md cursor-pointer"
            size="xlarge"
            @click="editAvatar"
          />
          <InputGroup>
            <InputText
              severity="contrast"
              size="small"
              placeholder="昵称"
              v-model:model-value="tmpNickname"
              @keydown.enter="editNickname"
            />
            <Button severity="contrast" size="small" class="m-0" @click="editNickname"
              ><Icon name="material-symbols:check-rounded"
            /></Button>
          </InputGroup>
        </div>

        <Divider />

        <div class="flex flex-row items-center justify-between">
          <p class="text-sm">{{ $t('label.autoConfirmBySender') }}</p>
          <ToggleSwitch v-model="isConfirmDefault" @change="switchConfirmDefault" />
        </div>
      </div>
    </Popover>

    <div class="contents">
      <NuxtLink to="https://www.buymeacoffee.com/shouchen" target="_blank" class="ml-2 md:ml-4">
        <Button severity="warning" text size="small" class="py-3" aria-label="Buy Me A Coffee">
          <IconCoffee class="size-5 text-black dark:text-white/90" />
        </Button>
      </NuxtLink>

      <Button
        severity="secondary"
        text
        @click="switchI18n"
        size="small"
        class="py-3"
        aria-label="Language"
      >
        <Icon
          name="icon-park-outline:chinese"
          class="text-black/90 dark:text-white/90"
          v-if="locale === 'zh'"
        />
        <Icon
          name="icon-park-outline:english"
          class="text-black/90 dark:text-white/90"
          v-else-if="locale === 'en'"
        />
      </Button>

      <!-- <Popover ref="i18nPopover">
        <Listbox
          v-model="selectedLocale"
          :options="availableLocales"
          optionLabel="name"
          class="border-0"
          ><template #option="slotProps">
            <div class="flex items-center gap-2 text-sm">
              <Icon :name="slotProps.option.icon" />
              <div>{{ slotProps.option.name }}</div>
            </div>
          </template>
        </Listbox>
      </Popover> -->

      <Button
        severity="secondary"
        text
        @click="switchColorMode"
        size="small"
        class="py-3"
        aria-label="Dark"
      >
        <Icon
          name="solar:moon-linear"
          class="text-yellow-500/90"
          v-if="colorMode.preference === 'dark'"
        />
        <Icon name="solar:sun-broken" class="text-black" v-else />
      </Button>
    </div>
  </nav>
</template>

<style scoped>
.nav-bar {
  transition: backdrop-filter 0.5s ease;
}
</style>
