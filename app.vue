<script setup lang="ts">
useSeoMeta({
  ogTitle: 'Fast Send',
  ogType: 'website',
  ogImage: 'https://send.liushen.fun/ogImg.webp',
  twitterCard: 'summary_large_image',
  twitterTitle: 'Fast Send',
  twitterDescription: 'Fast peer-to-peer file and directory transfers',
  twitterImage: 'https://send.liushen.fun/ogImg.webp',
  twitterSite: '@ShouChen_',
  twitterCreator: '@ShouChen_'
})

const deferredPrompt = useState('deferredPrompt')

onMounted(() => {
  window.addEventListener('beforeinstallprompt', (e) => {
    deferredPrompt.value = e
    // console.log(e)
  })
  useFullScreenLoader(false)

  fetch('/banner.txt')
    .then((res) => res.text())
    .then(console.log)
})
</script>

<template>
  <NuxtPwaManifest />
  <NuxtRouteAnnouncer />
  <FullScreenLoader />
  <Toast position="top-right" />
  <NavBar />
  <NuxtPage />
  <AppFooter />
  <ScrollTop />
  <InstallPWA />
  <DocPanel />
</template>
