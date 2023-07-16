'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "c3208afe8954c04096352d29cc8da762",
"assets/AssetManifest.json": "cd8edee5137c2e696910c1cb879eb12e",
"assets/assets/animation/1.json": "4327a6f54dcf59d8ca9e5edc088609e3",
"assets/assets/animation/2.json": "c17f786d1eda65296df13ddcbbe8e0b1",
"assets/assets/animation/3.json": "9747241d8b6b083ca8b806265eecd309",
"assets/assets/animation/4.json": "18c998b9642171daeffeb47c13b207a4",
"assets/assets/animation/NOVAanimation-mobile.gif": "2c171c5f6023d7cc0c3762d24747cd75",
"assets/assets/animation/NOVAanimation-mobile_dark.gif": "9a3fa04b0f1eda409e0415f693b566f7",
"assets/assets/animation/NOVAanimation-web.gif": "21bb784030d261a28fbbe029c601e74f",
"assets/assets/animation/NOVAanimation-web_dark.gif": "955e0b346725bd1a1e8336796a09022a",
"assets/assets/animation/NovaAnimation.json": "f4146f5a817dfb53b232b5074f10ec08",
"assets/assets/animation/NovaAnimation.mp4.lottie.json": "aa63de0c9b92d022717d7bfe1adfa4bd",
"assets/assets/icon/3dgifmaker67696.gif": "f4b1ba126ad9d7c86419a052e6095609",
"assets/assets/icon/building.png": "bf586b75cee141084765e00c02429488",
"assets/assets/icon/buildingicon.png": "21fd45a3e8ddb29113094c09f61777d3",
"assets/assets/icon/bus.png": "221006a37f991930cb619b4c7a12ee1b",
"assets/assets/icon/currentLocation.png": "aaf6cee552fb562e1f086f5e909cbc84",
"assets/assets/icon/english_flag.png": "462109358e5e62d9e9aaa873260d9a1e",
"assets/assets/icon/gates.png": "955e970fe6a0ee556ce13fa716e6ab51",
"assets/assets/icon/ICON_UNILINK-03.png": "934f2ddc55b3b16a77c84f469605fa92",
"assets/assets/icon/movingLocation.png": "8e7acf2afc1ff066d90cee54c6b6aa9f",
"assets/assets/icon/output.gif": "3dec616377ad62766572ed28ff9e0294",
"assets/assets/icon/Parking.png": "644bc866cfa24e97564c4c8585b519bf",
"assets/assets/icon/portuguese_flag.png": "ed9a2f9803e6353115c2de060e6b840b",
"assets/assets/icon/restaurant.png": "375b0f8f9a8d095a7f204e0f734507d1",
"assets/assets/icon/restaurant2.png": "ecf74e61cb30ae98686986ee7a06c4d5",
"assets/assets/icon/rotate3dUniHub.gif": "0e33fc77ba1229e684d8bfa8f7a74705",
"assets/assets/icon/service.png": "e10cd0ed3adf25313c4ddfdfa70052a4",
"assets/assets/icon/UniHub.gif": "b159a06b97ab2604336e8b59949dd587",
"assets/assets/icon/uniLinkBackground-03.png": "cfdc99975e5ae960fce928df0e8d1b64",
"assets/assets/icon/unilinkIcon-03.png": "46fbe5659a640a5fbcbee6b4b9c229ac",
"assets/assets/icon/unilinkIcon2.0-03-03.png": "147d49f97a2aa8144e7e6b5e3df131e5",
"assets/assets/icon/unilinkIcon2.1-03-03-03.png": "c5ca25671a450a8f25725a294bd63e27",
"assets/assets/icon/uniLinkIcon2.3-03.png": "905805341a5b2c4b1f3631d7c90040f5",
"assets/assets/images/background.jpg": "5a5d80a177c4d66650d394df7d614660",
"assets/assets/images/back_arrow.svg": "382715b7e7ab1a0f417953d8d4196e33",
"assets/assets/images/calendar_slider.png": "01336ad4462a47b8e0e074ac88b07eca",
"assets/assets/images/chat_slider.png": "efc20c68c538a125d6e06d163e830125",
"assets/assets/images/jumpIn_slider.png": "36488a15452223b964cea84a15aed335",
"assets/assets/images/locationArrow.png": "3688c6e91c2ff533572a2ae8531c37f5",
"assets/assets/images/logo%2520fct.png": "4d2b15d3f9a415d0c8065e71f220dbe4",
"assets/assets/images/map_slider.png": "ebac57cedaf2b2525ef67b7489746527",
"assets/assets/images/news_slider.png": "2996648e441fda8219d9c3a637db8a9e",
"assets/assets/images/NOVA_Logo.png": "53f9c022319aa21d52f9d9b53b611da6",
"assets/assets/images/NOVA_Logo_whiteBg.png": "797892d402fc6cceaa9db953dff93398",
"assets/assets/images/university_slider.png": "e595ffa14cb64dfe96e365514a8e81ed",
"assets/assets/json/contacts.json": "665698351f36a15daabcc35063031f56",
"assets/assets/json/map/Campus_de_Caparica.json": "983deab005afed949965fb11ffaf6f3b",
"assets/assets/json/map/Edificios.json": "6e43805761a6220580b9c6a45f35dbb3",
"assets/assets/json/map/Espacos_de_refeicao.json": "a353704ed5325452bb8ec70368ebf39c",
"assets/assets/json/map/Parques_de_estacionamento.json": "00b59d317f7e040b0d536546ba9e5dd9",
"assets/assets/json/map/Portarias.json": "438aafe66c444a7e16bdf5219c6fa212",
"assets/assets/json/map/Servicos.json": "61a299b16a193aeafbd403f9376e2502",
"assets/assets/json/map/Transportes.json": "ad37b6819f421e331ed37f0c30fd8c55",
"assets/assets/json/map_style.json": "ca7ac23a9d4c5f646523acba142692a0",
"assets/assets/json/map_style_dark.json": "67b595bb2f659984d680d6f12cb48081",
"assets/assets/json/schedule.json": "2ecad8073b014bdd958d48850472674c",
"assets/assets/json/subtags.json": "6c317cea688598eca54298fab079e58b",
"assets/assets/json/tags.json": "5ae0a2c1af4f1514d31dfa80d096a7ea",
"assets/assets/videos/novaAnimation-mobile.mp4": "15517155ec851fb9123ec83320321be6",
"assets/assets/videos/novaAnimation-web.mp4": "6592e1a022e2d81cca11acb8fe7dffab",
"assets/assets/videos/novaanimation.m3u8": "18b895d2f0ebb12102a4d0aecb69f07e",
"assets/FontManifest.json": "5a32d4310a6f5d9a6b651e75ba0d7372",
"assets/fonts/MaterialIcons-Regular.otf": "97495217c8b3f5807fac425988dc43ea",
"assets/NOTICES": "b1891aa5d0e05909facfd93205b45899",
"assets/packages/circle_flags/assets/png/ac.png": "7a22b00440fc343886cb7527fae8632f",
"assets/packages/circle_flags/assets/png/ad.png": "d026729924482a576374e567550f5c14",
"assets/packages/circle_flags/assets/png/ae.png": "2475bad00ef171913d44e24b91583f8e",
"assets/packages/circle_flags/assets/png/af.png": "da95d3f0b8cea81ba8b8f48a401855df",
"assets/packages/circle_flags/assets/png/ag.png": "82fbe0da0e182637b3a0aa7fee4d572d",
"assets/packages/circle_flags/assets/png/ai.png": "05dd008915bca22195bab3a4bec40893",
"assets/packages/circle_flags/assets/png/al.png": "2b2afdbae0aaf1a40f193032f7149ea3",
"assets/packages/circle_flags/assets/png/am.png": "4b21343422176867a1a06e289fd0d830",
"assets/packages/circle_flags/assets/png/ao.png": "da8a14eb09d5623451202b119cd8875e",
"assets/packages/circle_flags/assets/png/aq.png": "c380da292c04230d58a32aa4d1cb638a",
"assets/packages/circle_flags/assets/png/ar.png": "862cd82aa0149c99ad07ad687007e007",
"assets/packages/circle_flags/assets/png/as.png": "68a3a86011d510963820772d6e660032",
"assets/packages/circle_flags/assets/png/at.png": "973ad9b49d274f436d84ac191af9980d",
"assets/packages/circle_flags/assets/png/au.png": "da2e9c8d65cd5f0ee61a61d112bd10fe",
"assets/packages/circle_flags/assets/png/aw.png": "b493ba958779b152c8d5769ee4876912",
"assets/packages/circle_flags/assets/png/ax.png": "311d81deea8b75ab367084de6fc774e2",
"assets/packages/circle_flags/assets/png/az.png": "e95a312ef130514288f68fb9befc02c9",
"assets/packages/circle_flags/assets/png/ba.png": "489201ff16f2eec3ccdf16d34dbe23bd",
"assets/packages/circle_flags/assets/png/bb.png": "8997096f8fe86651301370d083988b87",
"assets/packages/circle_flags/assets/png/bd.png": "22c1113778b47d3de3c76eb236359962",
"assets/packages/circle_flags/assets/png/be.png": "87bd39e440de14cdef19bf819ddaa5ad",
"assets/packages/circle_flags/assets/png/bf.png": "a6d37368d2db13e2af67793b13be544a",
"assets/packages/circle_flags/assets/png/bg.png": "17bcacec27847fb8ea1b83b2b2e1cf5e",
"assets/packages/circle_flags/assets/png/bh.png": "b213a80640d00e9c91bae0e6661fc514",
"assets/packages/circle_flags/assets/png/bi.png": "8dd4730e34f4d0743c690f547c62642a",
"assets/packages/circle_flags/assets/png/bj.png": "03239348f8af6ee6839a2d000827390b",
"assets/packages/circle_flags/assets/png/bl.png": "00d012b1060a902be0fd1ecca524d7cb",
"assets/packages/circle_flags/assets/png/bm.png": "cae6c6d1f178038ba210366bb1a87706",
"assets/packages/circle_flags/assets/png/bn.png": "b4bd12e6666f48822a2d921aa4f2d69c",
"assets/packages/circle_flags/assets/png/bo.png": "45a50332673fc460639a51eb1a170a2c",
"assets/packages/circle_flags/assets/png/bq-sa.png": "4c234acae2cbda32da92c5891c5b37e6",
"assets/packages/circle_flags/assets/png/bq-se.png": "f9d20509478d825f2a4bf36ed7327828",
"assets/packages/circle_flags/assets/png/bq.png": "901af73ebde62a11bf1e3625c132d3b5",
"assets/packages/circle_flags/assets/png/br.png": "c56e8e2fc8d408dc03cecbdc49e71cdb",
"assets/packages/circle_flags/assets/png/bs.png": "32aa44e67c108625166849d7b42c017b",
"assets/packages/circle_flags/assets/png/bt.png": "82a287cf68d53488d71ce42d40b3da77",
"assets/packages/circle_flags/assets/png/bw.png": "997e771763e1c1ff39a4a87e32d576d4",
"assets/packages/circle_flags/assets/png/by.png": "58e51fa96a1cf7dc2c09bf8749f36f45",
"assets/packages/circle_flags/assets/png/bz.png": "6c11249aa4dd585088e85b28ea9533fa",
"assets/packages/circle_flags/assets/png/ca-bc.png": "767532585ec6dcf78557df1199ad4afd",
"assets/packages/circle_flags/assets/png/ca.png": "1e71c4aa2370ae162f5c1f1fdd289cc5",
"assets/packages/circle_flags/assets/png/cc.png": "6c4a305245fefd645e47e7f3b2c8f7aa",
"assets/packages/circle_flags/assets/png/cd.png": "13188adec950a6c587a89a010af94508",
"assets/packages/circle_flags/assets/png/cf.png": "f6cf4ec5d8f64bf13292905aa785c800",
"assets/packages/circle_flags/assets/png/cg.png": "772685534eda5a109d88b75ef855fa26",
"assets/packages/circle_flags/assets/png/ch.png": "489e197e274a8bf1a40e122695e0d1b5",
"assets/packages/circle_flags/assets/png/ci.png": "13de0aa8a02af034ae75b03e36dbb2ea",
"assets/packages/circle_flags/assets/png/ck.png": "6389c96af70ebea2d01ed1492ccb88ad",
"assets/packages/circle_flags/assets/png/cl.png": "9e35474fbae95627c4655feb86fc430b",
"assets/packages/circle_flags/assets/png/cm.png": "77c011d3a844106778af152ad8705e8c",
"assets/packages/circle_flags/assets/png/cn.png": "d195fb7b5514cc87d532a40cb7e21725",
"assets/packages/circle_flags/assets/png/co.png": "6bcc16d836d499a6e2a20ea3678e4174",
"assets/packages/circle_flags/assets/png/cr.png": "1dfa04df7e081630250ccd89ab86daca",
"assets/packages/circle_flags/assets/png/cu.png": "26a329291af8b0658a4e66463dc87855",
"assets/packages/circle_flags/assets/png/cv.png": "b7ce3cf87b665cdeb38d3a8d14703d05",
"assets/packages/circle_flags/assets/png/cw.png": "c3d71fa27e21e1af13e3cee9c7b344b8",
"assets/packages/circle_flags/assets/png/cx.png": "f26ddb490212cdcc273fd59c817c6e7a",
"assets/packages/circle_flags/assets/png/cy.png": "7feff3aa834a18031641abc99218aef9",
"assets/packages/circle_flags/assets/png/cz.png": "20842c21c4e53d3f2f0319017293fdc0",
"assets/packages/circle_flags/assets/png/de.png": "474b2630ce75bb4afd48717f679ad293",
"assets/packages/circle_flags/assets/png/dj.png": "b610c0b0c50de1e5cd8d341040e84764",
"assets/packages/circle_flags/assets/png/dk.png": "dc75a73a1ca6b5cd3bfce3f6f7abef2d",
"assets/packages/circle_flags/assets/png/dm.png": "0a60eb36303203f60df5fd94775476dc",
"assets/packages/circle_flags/assets/png/do.png": "7ccacc7ce965c6ba7ee992efd0c33e4b",
"assets/packages/circle_flags/assets/png/dz.png": "66074fc63aefb37bfee26101e1daf6a0",
"assets/packages/circle_flags/assets/png/easter_island.png": "85305969159afca9552e2288acde0dc7",
"assets/packages/circle_flags/assets/png/ec-w.png": "5788ea7c10113fe8e2585627486c491c",
"assets/packages/circle_flags/assets/png/ec.png": "1fba242c22fe4d69da52049a7d0d7075",
"assets/packages/circle_flags/assets/png/ee.png": "a7f246d8ee66d90512a266756319b40a",
"assets/packages/circle_flags/assets/png/eg.png": "f918695c766a4b611f6b6298e61aa1d0",
"assets/packages/circle_flags/assets/png/eh.png": "bdf4d6114caa924fd955490c7cbaecc4",
"assets/packages/circle_flags/assets/png/er.png": "15709a85a3af722ec98aed2d47661672",
"assets/packages/circle_flags/assets/png/es-ce.png": "c7a1e1821d454f655fc651a2bcbb6be5",
"assets/packages/circle_flags/assets/png/es-cn.png": "1f8e343ed36e39d2657788441ab5e564",
"assets/packages/circle_flags/assets/png/es-ga.png": "add7577250091c209e3bad7d098fcb02",
"assets/packages/circle_flags/assets/png/es-ib.png": "5792251c97cc023666c6a2c27c780595",
"assets/packages/circle_flags/assets/png/es-ml.png": "ad688fb9d7ffe82191d9e2f93bf23a85",
"assets/packages/circle_flags/assets/png/es-pv.png": "7d6ecd9a46469d64bad30d939074b069",
"assets/packages/circle_flags/assets/png/es-variant.png": "404c6c5cc8580d0695ff016f2392fadf",
"assets/packages/circle_flags/assets/png/es.png": "78e2ac241abb207aef1274989b115e46",
"assets/packages/circle_flags/assets/png/esperanto.png": "99293daa38185c10d483943cfeb3a648",
"assets/packages/circle_flags/assets/png/et.png": "93df8c684ef99747359fc82d8ec1753a",
"assets/packages/circle_flags/assets/png/european_union.png": "f0409361f1a93a43f032f791027b77c9",
"assets/packages/circle_flags/assets/png/fi.png": "41c7875dcfc2401156cd1a975a57a956",
"assets/packages/circle_flags/assets/png/fj.png": "7fc1091160cd41222e0803fba2df967b",
"assets/packages/circle_flags/assets/png/fk.png": "dc86c3286f4c1d5d3c4c78e77967f4cc",
"assets/packages/circle_flags/assets/png/fm.png": "e43c8abdb8bb57715d97baffc6b91536",
"assets/packages/circle_flags/assets/png/fo.png": "5bf01ea066a4f466f8b9dfaafe9f52d4",
"assets/packages/circle_flags/assets/png/fr-h.png": "687dca007d5c456a0c0317eac57e214c",
"assets/packages/circle_flags/assets/png/fr.png": "82453b843f5958038b44b920fa729383",
"assets/packages/circle_flags/assets/png/ga.png": "09827603f0ffffb928d798dca330c964",
"assets/packages/circle_flags/assets/png/gb-eng.png": "92196ea37e204d280ad8999ce59e76ce",
"assets/packages/circle_flags/assets/png/gb-ork.png": "34e4d279ed022039376750e1a9d19a12",
"assets/packages/circle_flags/assets/png/gb-sct.png": "e3b3460376017787993531b24e89b38e",
"assets/packages/circle_flags/assets/png/gb-wls.png": "2ad048be682195d86f898754ab1904ad",
"assets/packages/circle_flags/assets/png/gb.png": "68c4e1cd63e0be4f7a981095a6e71236",
"assets/packages/circle_flags/assets/png/gd.png": "4a195b258ee5dae59a3e479acf942264",
"assets/packages/circle_flags/assets/png/ge-ab.png": "297250baf87e0599d8816eb5e3e949de",
"assets/packages/circle_flags/assets/png/ge.png": "83c2d395c07be383c180ef251d85069d",
"assets/packages/circle_flags/assets/png/gf.png": "0f3703af70eecf8eea79d1447879efb7",
"assets/packages/circle_flags/assets/png/gg.png": "c790aef67bb77011c1517904bbbf064a",
"assets/packages/circle_flags/assets/png/gh.png": "db0fc3bbc7a9585a30a6988af95f25bb",
"assets/packages/circle_flags/assets/png/gi.png": "eb6c5b964b3076e1fda99f31886a3680",
"assets/packages/circle_flags/assets/png/gl.png": "85a1d09bf6af5be1296580d5ee16fdc6",
"assets/packages/circle_flags/assets/png/gm.png": "a40a1cfad16141b44d8ddd1b55da9938",
"assets/packages/circle_flags/assets/png/gn.png": "c3f16d722d67249f369a7ee751b21555",
"assets/packages/circle_flags/assets/png/gp.png": "44812acc8ca3285722d2626d58c394b1",
"assets/packages/circle_flags/assets/png/gq.png": "f99f1ff056ad75a8fc58632ec1470bbc",
"assets/packages/circle_flags/assets/png/gr.png": "c12a0c41fb0eb0662d50242e986b87d0",
"assets/packages/circle_flags/assets/png/gs.png": "2632a27558f6f9359b7a47a575da3eb2",
"assets/packages/circle_flags/assets/png/gt.png": "b5f6615461e1806b843b12b664caeb1c",
"assets/packages/circle_flags/assets/png/gu.png": "36c1cf1f5c9a8fc264b0e40dbae3ee1b",
"assets/packages/circle_flags/assets/png/gw.png": "06124bf80828f22325c5b2af36af424f",
"assets/packages/circle_flags/assets/png/gy.png": "aef6eb2f00f811518dcab0db5b6ee7dc",
"assets/packages/circle_flags/assets/png/hausa.png": "fd867f777142484216dec4f77120b645",
"assets/packages/circle_flags/assets/png/hk.png": "8ac9f0a83d770c2af361d1e32b49e3aa",
"assets/packages/circle_flags/assets/png/hl.png": "34bd43e622e19948031d6b246b7ea896",
"assets/packages/circle_flags/assets/png/hmong.png": "f3338752cdcc4d2f6f8c7db82ff90bcd",
"assets/packages/circle_flags/assets/png/hn.png": "81081cb2b7ec1c8a3f8c06bf32fd68b1",
"assets/packages/circle_flags/assets/png/hr.png": "cb1f18abf3dc426cb903e36a1d6b2cda",
"assets/packages/circle_flags/assets/png/ht.png": "0fb11dd34bca49b7a89b2f9fda3f40f3",
"assets/packages/circle_flags/assets/png/hu.png": "15791204f65417155fb2fbb825a6a3ad",
"assets/packages/circle_flags/assets/png/id.png": "bf9588cefdf79ca61ef1ca9818f92ac5",
"assets/packages/circle_flags/assets/png/ie.png": "a14a899e7e3dc6e9ef47e068782d51c8",
"assets/packages/circle_flags/assets/png/il.png": "af9f6d5ebc5b41dbeb34ba0f3c7331aa",
"assets/packages/circle_flags/assets/png/im.png": "7ca1175e4b7bba5d9c1eac269287c4da",
"assets/packages/circle_flags/assets/png/in.png": "80f1c0a67546fdd0e01b5e2f7f6f8f92",
"assets/packages/circle_flags/assets/png/io.png": "74a027f89d5b1ffe6ada20212570f0c8",
"assets/packages/circle_flags/assets/png/iq.png": "f12bd62768eaf49098a6fffa1772dc0a",
"assets/packages/circle_flags/assets/png/ir.png": "791d45bf1175eb0e02a055597fff4ae3",
"assets/packages/circle_flags/assets/png/is.png": "e286eabff56d0cab4c6c4a0bd129a2e5",
"assets/packages/circle_flags/assets/png/it-82.png": "822212f8334d551ba55142deb17a0b18",
"assets/packages/circle_flags/assets/png/it-88.png": "38c05c70ef83e86329f66cf57735c756",
"assets/packages/circle_flags/assets/png/it.png": "c7156f29ac90d4127c6b0a9e5c3c927b",
"assets/packages/circle_flags/assets/png/je.png": "92fcff04ed40eea4469e5dc76f6cff5c",
"assets/packages/circle_flags/assets/png/jm.png": "f3f399f215000683dee4f77b6a8cd018",
"assets/packages/circle_flags/assets/png/jo.png": "a49d368561934016ab53383d53b64ba9",
"assets/packages/circle_flags/assets/png/jp.png": "2c8b2c68f404390435305646fdda1d79",
"assets/packages/circle_flags/assets/png/kannada.png": "fd9a009f56b5f72fae1e7bd4ef9284c9",
"assets/packages/circle_flags/assets/png/ke.png": "41dd59fb85265774e268f9940640f4a8",
"assets/packages/circle_flags/assets/png/kg.png": "875b16f7e0ace23c9cf98422500df0e9",
"assets/packages/circle_flags/assets/png/kh.png": "4a27a6b9d74d054d405b7f37619355a5",
"assets/packages/circle_flags/assets/png/ki.png": "8e6c528221109b98b099559fc10352a3",
"assets/packages/circle_flags/assets/png/km.png": "25d2218002b3e7da0cecd442168fb4bd",
"assets/packages/circle_flags/assets/png/kn.png": "3547bf07fe419da3bb738c660e5a3156",
"assets/packages/circle_flags/assets/png/kp.png": "d265a97f577a4f110da9b40ccffccd4c",
"assets/packages/circle_flags/assets/png/kr.png": "8ef5284cb12c9a8f84c1163a229f3d40",
"assets/packages/circle_flags/assets/png/kurdistan.png": "046cc4de66cb95585a94d355d55bb271",
"assets/packages/circle_flags/assets/png/kw.png": "7e00bb598fdc9fc624e1fe27d40bb5e5",
"assets/packages/circle_flags/assets/png/ky.png": "2681f255a065be62966560904348a507",
"assets/packages/circle_flags/assets/png/kz.png": "5db07dbaa2d968bd7901eafba6d557f5",
"assets/packages/circle_flags/assets/png/la.png": "d7f4c9ff3306decd74c61c08d7c2af21",
"assets/packages/circle_flags/assets/png/lb.png": "9ce213e0530f5d331255982714932835",
"assets/packages/circle_flags/assets/png/lc.png": "b4554713ebff8bb863160ab4c956d3b9",
"assets/packages/circle_flags/assets/png/li.png": "0cf84ee5c23055e2117134581456d512",
"assets/packages/circle_flags/assets/png/lk.png": "db8f4aee9f23fbb771f6c95518035e3f",
"assets/packages/circle_flags/assets/png/lr.png": "2284a93437a8b9f212ed4e16018150d9",
"assets/packages/circle_flags/assets/png/ls.png": "fda8a09c4d59446625aebe9ebb229764",
"assets/packages/circle_flags/assets/png/lt.png": "d4b972884586dcf92fdb3ef29dc0eca0",
"assets/packages/circle_flags/assets/png/lu.png": "2439199e7cf85c6e22f0a2b9fe15315a",
"assets/packages/circle_flags/assets/png/lv.png": "b237758ac4c804301b9f203f648c1b39",
"assets/packages/circle_flags/assets/png/ly.png": "c9d75546effbfcf907e45201058f0ebb",
"assets/packages/circle_flags/assets/png/ma.png": "5c2cbfd6cf417f3c400358e5cdf8288c",
"assets/packages/circle_flags/assets/png/malayali.png": "f73f11f98ca952d4caae8c187e7768d9",
"assets/packages/circle_flags/assets/png/maori.png": "36ee78f8ae595872ea5d6ce01b32880f",
"assets/packages/circle_flags/assets/png/mc.png": "6cdbf2451731e1bd9b405e1dc19c5383",
"assets/packages/circle_flags/assets/png/md.png": "5fb6d946ec5bd47478538c95c95fef6f",
"assets/packages/circle_flags/assets/png/me.png": "cc268bcd9746d5fe04f3a5729c6b6d2c",
"assets/packages/circle_flags/assets/png/mf.png": "255c99edcd31fb2d3c760202a677b1b6",
"assets/packages/circle_flags/assets/png/mg.png": "c962021492eb56552a2dc027b120eb6a",
"assets/packages/circle_flags/assets/png/mh.png": "ade5568fb3a7f08bc7fc039fe7894cdf",
"assets/packages/circle_flags/assets/png/mk.png": "c0696c47c156029c8e409375acb75ae2",
"assets/packages/circle_flags/assets/png/ml.png": "6b61b40ded984ae4f246f3dbc89da8e2",
"assets/packages/circle_flags/assets/png/mm.png": "f2fc9609ea54f87480b17dedfc9e69dc",
"assets/packages/circle_flags/assets/png/mn.png": "d4b60dc615b3c7636ca9d38a1f90887b",
"assets/packages/circle_flags/assets/png/mo.png": "6d86aead270e125f67c9bd2f87875e85",
"assets/packages/circle_flags/assets/png/mp.png": "14d689d9560748e571141bd715762f81",
"assets/packages/circle_flags/assets/png/mq.png": "e68b26b02f3e76827eeb51471b939bbf",
"assets/packages/circle_flags/assets/png/mr.png": "8c10ee246a65dea1ddcbd21e434695e5",
"assets/packages/circle_flags/assets/png/ms.png": "fbf56d56d143e5d68a08655ed77c01d4",
"assets/packages/circle_flags/assets/png/mt.png": "8b94c5c93d82685fc3380e0d1d853633",
"assets/packages/circle_flags/assets/png/mu.png": "9c5abcdaa5e35cbc72eb589dae2d9e0a",
"assets/packages/circle_flags/assets/png/mv.png": "3a995828df0fdcc707cfdf5783f0157d",
"assets/packages/circle_flags/assets/png/mw.png": "bb58dd3cea34d822c84527736ad00aee",
"assets/packages/circle_flags/assets/png/mx.png": "cc6c86e49a1a1820d96d4edce31c4fbc",
"assets/packages/circle_flags/assets/png/my.png": "43420d95ddd6a7fbad83e3a465af2044",
"assets/packages/circle_flags/assets/png/mz.png": "2d3798d8bb448e4d131f04c8ee477b9e",
"assets/packages/circle_flags/assets/png/na.png": "6c8d8cc2ef5ae254091725da4ecc9c23",
"assets/packages/circle_flags/assets/png/nato.png": "4cb32a73b619a3f2e8af2d781ef5ce9a",
"assets/packages/circle_flags/assets/png/nc.png": "b768d0498582f77f64a7351f26436a17",
"assets/packages/circle_flags/assets/png/ne.png": "f37bb2c062bddc072c3d20df8cd2f36a",
"assets/packages/circle_flags/assets/png/nf.png": "61d50d97ecf0566085686136450cb5bd",
"assets/packages/circle_flags/assets/png/ng.png": "f2251d80d787e8e5a4a594210347dce2",
"assets/packages/circle_flags/assets/png/ni.png": "e3ab6b9db1b69db67b5b358f1e41dd65",
"assets/packages/circle_flags/assets/png/nl.png": "b7434a6b35bfc0b68370cda1f9ecf2c8",
"assets/packages/circle_flags/assets/png/no.png": "8b81e3c86f4ff4f92b9e80b95af72c59",
"assets/packages/circle_flags/assets/png/northern_cyprus.png": "5a56ef8402393d475a56e1db4f41f99c",
"assets/packages/circle_flags/assets/png/np.png": "8dd7ed2aa0e791f65b70cbb41e8ed763",
"assets/packages/circle_flags/assets/png/nr.png": "6211f466e39cce7d8ee06ce9b42c9d40",
"assets/packages/circle_flags/assets/png/nu.png": "93f588781c195e3436629698e070438e",
"assets/packages/circle_flags/assets/png/nz.png": "f772f30544b4272d64f440114d4ddadd",
"assets/packages/circle_flags/assets/png/om.png": "79e8cbadbd0c47316db4bd14f3072567",
"assets/packages/circle_flags/assets/png/pa.png": "dc6ca6fc12b17da035161b2efd5e4511",
"assets/packages/circle_flags/assets/png/pe.png": "7fe8d438e64ce655cf3dfce33b580ecd",
"assets/packages/circle_flags/assets/png/pf.png": "16edae498454cfa205c702d3a4200b78",
"assets/packages/circle_flags/assets/png/pg.png": "0785afcf5b79c2465a75564e753a034a",
"assets/packages/circle_flags/assets/png/ph.png": "17f2147cb5f1715b00e97d30f23d4f15",
"assets/packages/circle_flags/assets/png/pk.png": "15b73b4406b19432b83b7d3212f0f1af",
"assets/packages/circle_flags/assets/png/pl.png": "804cc193c6f217d7c8d86a586a837db1",
"assets/packages/circle_flags/assets/png/pm.png": "9f3ef6d933f360e80ad7348543bcd516",
"assets/packages/circle_flags/assets/png/pn.png": "44b994dc30501e4f74d309abed1f5b25",
"assets/packages/circle_flags/assets/png/pr.png": "c362f82a1646c7abbe8841c4dbee13f5",
"assets/packages/circle_flags/assets/png/ps.png": "d3f2042a961bf3dffae166b3d1b224d5",
"assets/packages/circle_flags/assets/png/pt-20.png": "59e4d5421fb702390902e2e5259195ef",
"assets/packages/circle_flags/assets/png/pt-30.png": "a4a7d0b6bf4295d01fc8b796ebc11ead",
"assets/packages/circle_flags/assets/png/pt.png": "bf0f38de3f45f05dbfbe82233de89a1f",
"assets/packages/circle_flags/assets/png/pw.png": "881bdd8284d19fbac63f4993c38cdd7f",
"assets/packages/circle_flags/assets/png/py.png": "e5523b516f85d9169af4b903a572a018",
"assets/packages/circle_flags/assets/png/qa.png": "84548374ed0a913ed868f79410840842",
"assets/packages/circle_flags/assets/png/re.png": "80b6c977e2860d0f713649ff34b4da89",
"assets/packages/circle_flags/assets/png/ro.png": "6acd28ac9cdfc77919be7cbc6e65f54f",
"assets/packages/circle_flags/assets/png/rs.png": "c04e702b963e3712cd1751f9d9a0848c",
"assets/packages/circle_flags/assets/png/ru.png": "85e6556c5282b36a1e3233487391c4ed",
"assets/packages/circle_flags/assets/png/rw.png": "db1aa6c22414a515d3678220be17fcec",
"assets/packages/circle_flags/assets/png/sa.png": "3fac06b28f2eab37f7b8fb5fae5200b4",
"assets/packages/circle_flags/assets/png/sb.png": "b5e77294c0fadf65e1e5d403db477de2",
"assets/packages/circle_flags/assets/png/sc.png": "af6d99ccaaecda838311fa910eda0c35",
"assets/packages/circle_flags/assets/png/sd.png": "03e75bd807d6adaa763a6cd2c25fbe6a",
"assets/packages/circle_flags/assets/png/se.png": "7d575d81f4faca8ed85146b9a5387e81",
"assets/packages/circle_flags/assets/png/sg.png": "db28a351472baaea06dac1401c98b562",
"assets/packages/circle_flags/assets/png/si.png": "4ad0749e98da508a4c8318f027f19465",
"assets/packages/circle_flags/assets/png/sindh.png": "72bb069f56b4a6e434da4e770f8cd8d3",
"assets/packages/circle_flags/assets/png/sk.png": "bbd75566cfe6549be8c0ba1e49115665",
"assets/packages/circle_flags/assets/png/sl.png": "04dbb9d68e39d762eb3716851a66a17d",
"assets/packages/circle_flags/assets/png/sm.png": "95929200e77bb36656df23a1b7839f5f",
"assets/packages/circle_flags/assets/png/sn.png": "b0e285ae74fdf2f579d9efbcfb168bff",
"assets/packages/circle_flags/assets/png/so.png": "d6a293cb2cdcbcace095f2c4df86870e",
"assets/packages/circle_flags/assets/png/somaliland.png": "a682ecfe2785dea18d74cf54782d7fd5",
"assets/packages/circle_flags/assets/png/south_ossetia.png": "7aeb4b42406ac9283f2f30a566cb3d0e",
"assets/packages/circle_flags/assets/png/sr.png": "c9b2b32d36dd92363bd80a44cb838a23",
"assets/packages/circle_flags/assets/png/ss.png": "afad671d0364fd7fc98b78dbaaadfd6e",
"assets/packages/circle_flags/assets/png/st.png": "2623c362c8195137ed794ba29931132f",
"assets/packages/circle_flags/assets/png/sv.png": "63d6bceb1fe2f1e96bcf03f71315ea24",
"assets/packages/circle_flags/assets/png/sx.png": "3e690404f3fe8559b4b255021f8e3046",
"assets/packages/circle_flags/assets/png/sy.png": "34d845a7dae686f1f4f20f85faa2f8f5",
"assets/packages/circle_flags/assets/png/sz.png": "b57da390f346f8b7e4a331e74d33a6f5",
"assets/packages/circle_flags/assets/png/ta.png": "4a3733f093a4c820fb3dfedaa3a7e1e5",
"assets/packages/circle_flags/assets/png/tc.png": "ba30648e4604387c124c8adaab580a8e",
"assets/packages/circle_flags/assets/png/td.png": "ea1300c3bc1beb7dbec4b01587a9a306",
"assets/packages/circle_flags/assets/png/tf.png": "5f383d301231576985d353f92b08cbfa",
"assets/packages/circle_flags/assets/png/tg.png": "77e16fe9855f2ba1b73406c7d34197f8",
"assets/packages/circle_flags/assets/png/th.png": "7a9640b692bd226fb58cb73df77154cc",
"assets/packages/circle_flags/assets/png/tibet.png": "9031f53024e200b247572c0e4d09c4ac",
"assets/packages/circle_flags/assets/png/tj.png": "6d6cba19d6f622b76415f3dfce1d489f",
"assets/packages/circle_flags/assets/png/tk.png": "f86289fe48c83a129daf3689ee8bfca3",
"assets/packages/circle_flags/assets/png/tl.png": "64b6968cecff28a125882feb74e27de8",
"assets/packages/circle_flags/assets/png/tm.png": "065f5a3bc07ed2f49d604ec3fd45ecd7",
"assets/packages/circle_flags/assets/png/tn.png": "2fbad308820ca4c970b642dd12fd0e63",
"assets/packages/circle_flags/assets/png/to.png": "4c45019abb840109b4af36d2b7ced768",
"assets/packages/circle_flags/assets/png/tr.png": "46f618b8c7bfbe78b50f0f8b3124a2c5",
"assets/packages/circle_flags/assets/png/transnistria.png": "66b76ead422e02eda800d972f24fbb7e",
"assets/packages/circle_flags/assets/png/tt.png": "c9fb48c3b22e3b46e554203ff6ac97c3",
"assets/packages/circle_flags/assets/png/tv.png": "65db29a6af65cc8a8de95cdee5f84772",
"assets/packages/circle_flags/assets/png/tw.png": "41ad0673907c248046985bea2f9abbde",
"assets/packages/circle_flags/assets/png/tz.png": "8ac98cf61ae234c7fb7130aeeb591527",
"assets/packages/circle_flags/assets/png/ua.png": "1fe74a844a24821fd9376740dee33ed4",
"assets/packages/circle_flags/assets/png/ug.png": "9f15e8cb51e153ef2c2a030e14902db3",
"assets/packages/circle_flags/assets/png/united_nations.png": "99bb55e1b4280480e1dd6c0ceb8be930",
"assets/packages/circle_flags/assets/png/us-hi.png": "6de64dadd7da6f2175b02183f8875801",
"assets/packages/circle_flags/assets/png/us.png": "e14fb2673adda9a8dc006cab5d4c5f60",
"assets/packages/circle_flags/assets/png/uy.png": "ffa892d200746068cb355766bf6af294",
"assets/packages/circle_flags/assets/png/uz.png": "97762956a586758b5b935d2e8ff762c9",
"assets/packages/circle_flags/assets/png/va.png": "5e4f6687cd52bfc7a87b68393a5f499f",
"assets/packages/circle_flags/assets/png/vc.png": "bedb626d26b358f5d4cfaed9759b3d56",
"assets/packages/circle_flags/assets/png/ve.png": "5135d177f165669cb41ea3f2eb907eca",
"assets/packages/circle_flags/assets/png/vg.png": "22115158d1d53ed2977f6d1b44cddc9d",
"assets/packages/circle_flags/assets/png/vi.png": "f998bef967bc0f7c956e3b18bd9db0e8",
"assets/packages/circle_flags/assets/png/vn.png": "4ac778149e5035b04d06bb01106ab85e",
"assets/packages/circle_flags/assets/png/vu.png": "e56f8bce566ac1daeabf6c135c203124",
"assets/packages/circle_flags/assets/png/wf.png": "c246a8385285414b19d33ec78a65adb5",
"assets/packages/circle_flags/assets/png/ws.png": "70226de9ff41706f22f1565b3bb5aa9a",
"assets/packages/circle_flags/assets/png/xk.png": "7b28215457775eda8f6cdee057945e26",
"assets/packages/circle_flags/assets/png/xx.png": "24cc317b8152595c313338438b587a7f",
"assets/packages/circle_flags/assets/png/ye.png": "48afa49f8d8062ca13da159264833ca7",
"assets/packages/circle_flags/assets/png/yiddish.png": "d6e3adf3306a7ac9d41f367a298cdc29",
"assets/packages/circle_flags/assets/png/yt.png": "6c3de614459a60ec3395c819440d1855",
"assets/packages/circle_flags/assets/png/za.png": "71bc967c5dd27254f85816b0dcc51e64",
"assets/packages/circle_flags/assets/png/zm.png": "82a5c4ee674b98b1fb9412cf91a68427",
"assets/packages/circle_flags/assets/png/zw.png": "4d5b805fcdb4a56734eb70d23a6adbb6",
"assets/packages/country_flags/res/si/ac.si": "084b17449dd0ba76474f133039ee68d3",
"assets/packages/country_flags/res/si/ad.si": "c3ccb8e3cf8b3ce384280c687c94ed53",
"assets/packages/country_flags/res/si/ae.si": "600a0ce358d82ca58155a6298524084f",
"assets/packages/country_flags/res/si/af.si": "9fb0d66778b5afe46c5750f6b2de0a06",
"assets/packages/country_flags/res/si/ag.si": "f2607a0fcfd1aeecb45e1ea7d17979a0",
"assets/packages/country_flags/res/si/ai.si": "98108de6fc34688b9281b6040f855730",
"assets/packages/country_flags/res/si/al.si": "3a10d259f602c6832ed5316403f6fe91",
"assets/packages/country_flags/res/si/am.si": "f1c0decc96d76ecce7dda29e1b0a3048",
"assets/packages/country_flags/res/si/ao.si": "042c2a03c013acf928449dbaf2a4affe",
"assets/packages/country_flags/res/si/aq.si": "e15ec1a740dfd94250faaf3a04c3e009",
"assets/packages/country_flags/res/si/ar.si": "4ce98d701be0d5607ec3f0d62e5c7ff8",
"assets/packages/country_flags/res/si/as.si": "f12705f23ac102cc4fa8e85c3a780040",
"assets/packages/country_flags/res/si/at.si": "da9709351758847fbf187e9947fd44a5",
"assets/packages/country_flags/res/si/au.si": "93810e1a767ca77d78fa8d70ef89878a",
"assets/packages/country_flags/res/si/aw.si": "bac854c7bbf50dd71fc643f9197f4587",
"assets/packages/country_flags/res/si/ax.si": "a456e36511e13498fa3d610a026d79b8",
"assets/packages/country_flags/res/si/az.si": "203fdb6be0df02e0b86e1ab468a84588",
"assets/packages/country_flags/res/si/ba.si": "6719180c7b4f5d76a1c41fd76668cc69",
"assets/packages/country_flags/res/si/bb.si": "a0f7ccd01c2e5eee48607b53d0791941",
"assets/packages/country_flags/res/si/bd.si": "18bcbe7c5cd7ef99faf8e581dcf6f2db",
"assets/packages/country_flags/res/si/be.si": "6d9dd724fd5dd06b3cff71955bf03728",
"assets/packages/country_flags/res/si/bf.si": "36c828d75ffb1b1ee0c074f08dbd162e",
"assets/packages/country_flags/res/si/bg.si": "75bcf4b187601813fcf6008da5ef3625",
"assets/packages/country_flags/res/si/bh.si": "637d8c9177fdc8bf98d2afb4de3a3cbe",
"assets/packages/country_flags/res/si/bi.si": "4e22a5fa7d3657998c6424ee89ba328f",
"assets/packages/country_flags/res/si/bj.si": "e356b737969b4d0413d0d17781f5476f",
"assets/packages/country_flags/res/si/bl.si": "b319560213233391af1170881595344f",
"assets/packages/country_flags/res/si/bm.si": "2c1effe65d4c9c6ea846536f9ebcac93",
"assets/packages/country_flags/res/si/bn.si": "1334a282f886a35989ab2d1fee8b3acc",
"assets/packages/country_flags/res/si/bo.si": "1491a562f1ee0f5fdf512a72821dc3b1",
"assets/packages/country_flags/res/si/bq.si": "130b5b1f64baa8e002dc668b0d3d589f",
"assets/packages/country_flags/res/si/br.si": "dc32cd1c578da0b7106bd15a74434692",
"assets/packages/country_flags/res/si/bs.si": "5818730530c519e134452e41830a7d4b",
"assets/packages/country_flags/res/si/bt.si": "9b9f54fdaeb57d27628dd7318c23d632",
"assets/packages/country_flags/res/si/bv.si": "d2e12ff6011d4fc76d0044e61abbd8a1",
"assets/packages/country_flags/res/si/bw.si": "50b6724787e9b206d8998f747748f133",
"assets/packages/country_flags/res/si/by.si": "045e4e447111a76bb834bd9e969756b4",
"assets/packages/country_flags/res/si/bz.si": "3fad74bf2e5948e1556c8048e65e084e",
"assets/packages/country_flags/res/si/ca.si": "a911aefa8694f795f4066047492134be",
"assets/packages/country_flags/res/si/cc.si": "831df80000b0c6d12f0c37f696a11e31",
"assets/packages/country_flags/res/si/cd.si": "092862ef3f988f301bf81d937d0b2251",
"assets/packages/country_flags/res/si/cefta.si": "4a619e7166e3a91fd3333a0aa9a7f212",
"assets/packages/country_flags/res/si/cf.si": "00cce9e9924e59417fd640f22ff3c068",
"assets/packages/country_flags/res/si/cg.si": "a9df20410076c50e9abbd11b324712c3",
"assets/packages/country_flags/res/si/ch.si": "25b5af40c1ed5254d8a5c9286a235a78",
"assets/packages/country_flags/res/si/ci.si": "2dd6886cd9b611e8301f347233f275db",
"assets/packages/country_flags/res/si/ck.si": "30d75fc50470f00d7fc590c058b7a4c1",
"assets/packages/country_flags/res/si/cl.si": "1765b8d051900505b51ca7149756b62e",
"assets/packages/country_flags/res/si/cm.si": "d89b50b2a1e7c5814a53894ddf6842f6",
"assets/packages/country_flags/res/si/cn.si": "a629d6ea2863bc2e2783ed86427fccdf",
"assets/packages/country_flags/res/si/co.si": "471a020ee0695a4be6867c76e3e4fcdf",
"assets/packages/country_flags/res/si/cp.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/cr.si": "7385af5d3c967dad1c62027ece383dd6",
"assets/packages/country_flags/res/si/cu.si": "b561ce782460b38c99795d3891be4bd8",
"assets/packages/country_flags/res/si/cv.si": "1d61ed1ebf59c2a571f54da09340b52b",
"assets/packages/country_flags/res/si/cw.si": "8c2327f9686e6183f85b4141294f7944",
"assets/packages/country_flags/res/si/cx.si": "8d7a59ff653f34ab3323c39c5c5b2f75",
"assets/packages/country_flags/res/si/cy.si": "f4f95412e75e3e82b62b140f1fb4d327",
"assets/packages/country_flags/res/si/cz.si": "57831eb560349de7a9274604af4cda4d",
"assets/packages/country_flags/res/si/de.si": "aaabd585b21d0960b60d05acf4c54cd3",
"assets/packages/country_flags/res/si/dg.si": "3469f709b852fa25f3d735d4e7ee88a2",
"assets/packages/country_flags/res/si/dj.si": "c39ebb82ae2414d5b42b0c78d7db1626",
"assets/packages/country_flags/res/si/dk.si": "23b9112d01b91326804b173427d0a991",
"assets/packages/country_flags/res/si/dm.si": "114b039b7de692af992aa75bdfd324d9",
"assets/packages/country_flags/res/si/do.si": "0c12349ea290f3e7d6bd3c7eba8ec556",
"assets/packages/country_flags/res/si/dz.si": "74f32a3036da03823454cf8c2fbcc22f",
"assets/packages/country_flags/res/si/ea.si": "c59363bf0d9a595df07cfe238f9cc16a",
"assets/packages/country_flags/res/si/ec.si": "87d4beb1830c8746d02bd3eb81daa1cf",
"assets/packages/country_flags/res/si/ee.si": "d1d0e6c483ec14291ccafc69c4390f07",
"assets/packages/country_flags/res/si/eg.si": "eb6351aaa487d5e422ecd8f1160ada0d",
"assets/packages/country_flags/res/si/eh.si": "99373a71bd21ee4d5ce37dd840fa8bc5",
"assets/packages/country_flags/res/si/er.si": "1f32851695ad06a33b607cbfe96cbe5c",
"assets/packages/country_flags/res/si/es-ct.si": "9d497fc098e8ac8eb94576ca2b72a65a",
"assets/packages/country_flags/res/si/es-ga.si": "c128cec2feffaff7aab7940dadcd9ccd",
"assets/packages/country_flags/res/si/es.si": "c59363bf0d9a595df07cfe238f9cc16a",
"assets/packages/country_flags/res/si/et.si": "6020d43892ed1096172d0d01a00afe89",
"assets/packages/country_flags/res/si/eu.si": "0c7acf5338eb131940e6a2d53022fda7",
"assets/packages/country_flags/res/si/fi.si": "6ed37987c4dee7606f35b1f3ef2f4352",
"assets/packages/country_flags/res/si/fj.si": "5315abdde8d2a5274a621a7d1fdb92a6",
"assets/packages/country_flags/res/si/fk.si": "bcdc2242f7af2a72255f8d89d2642fe8",
"assets/packages/country_flags/res/si/fm.si": "d195abb2e8d6961f6ffa0da23d8b2813",
"assets/packages/country_flags/res/si/fo.si": "c074164f5875cc2ac648caa3461a4ffa",
"assets/packages/country_flags/res/si/fr.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/ga.si": "863042bec1c7781b8245d2fec2961835",
"assets/packages/country_flags/res/si/gb-eng.si": "c23da032fa2a18ca5390c2cab903ac80",
"assets/packages/country_flags/res/si/gb-nir.si": "70756040e8747ea10547485c1b5493dd",
"assets/packages/country_flags/res/si/gb-sct.si": "c1e2452023ede8ca68306f9360bec03f",
"assets/packages/country_flags/res/si/gb-wls.si": "bb7216967d97426e1d684b2745118f89",
"assets/packages/country_flags/res/si/gb.si": "b875cc97c8e2a1a41fd3ccbbdb63d291",
"assets/packages/country_flags/res/si/gd.si": "2bd89cc35d9a35aa6b5c7dfa8888e769",
"assets/packages/country_flags/res/si/ge.si": "6f700846562325e1e647946a9b7e26f6",
"assets/packages/country_flags/res/si/gf.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/gg.si": "57b684be8b0e0fa86e1dae5100f3c0ee",
"assets/packages/country_flags/res/si/gh.si": "21e46cb3743f96b4e47de0c0b277c604",
"assets/packages/country_flags/res/si/gi.si": "1d4b7516dbef91dd53a3223786433468",
"assets/packages/country_flags/res/si/gl.si": "f447d0f9f9e95027def4b4a333f59393",
"assets/packages/country_flags/res/si/gm.si": "b764f5bed08b62f0c908d224b61c62ce",
"assets/packages/country_flags/res/si/gn.si": "ebb9409ab8449de9d040549ffcef1321",
"assets/packages/country_flags/res/si/gp.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/gq.si": "e8e087ae91048f042fa212b5f79a496c",
"assets/packages/country_flags/res/si/gr.si": "a7ffe39d3dbd0f7e2d7cf03b38ebce8b",
"assets/packages/country_flags/res/si/gs.si": "d6e2a1be23c5e70fced629d467e0a1f7",
"assets/packages/country_flags/res/si/gt.si": "2841eca17a032575b20e97e3c4c0977e",
"assets/packages/country_flags/res/si/gu.si": "f47c5abf0b2dd4b8b717e87c82e1f328",
"assets/packages/country_flags/res/si/gw.si": "9c6f62e2963f012b571dad989416a1f3",
"assets/packages/country_flags/res/si/gy.si": "6373d2b94878202fd94563aeea4fd8ca",
"assets/packages/country_flags/res/si/hk.si": "cdc28623f40113eb4227c9ed796b6201",
"assets/packages/country_flags/res/si/hm.si": "93810e1a767ca77d78fa8d70ef89878a",
"assets/packages/country_flags/res/si/hn.si": "bf1d541bc8c0b4826c3cf7f2d36e1b87",
"assets/packages/country_flags/res/si/hr.si": "dc0efaf40fb58a21f52fd9a86c7ddfdc",
"assets/packages/country_flags/res/si/ht.si": "2f82778ff6d4910a677170a08545bfd6",
"assets/packages/country_flags/res/si/hu.si": "379f70d867e53920ef1105ae9d3dc5e1",
"assets/packages/country_flags/res/si/ic.si": "5459bbd72389b2300c7da170cd528f23",
"assets/packages/country_flags/res/si/id.si": "9cf3c91fee39a1ff1d93cbbe385d7bbf",
"assets/packages/country_flags/res/si/ie.si": "58082f0739794c2562fbd21b9700a0a9",
"assets/packages/country_flags/res/si/il.si": "5926479ae8ffa09647b9c20feceb9415",
"assets/packages/country_flags/res/si/im.si": "3bca9cb89673cd2c1837c69f72038bde",
"assets/packages/country_flags/res/si/in.si": "335a5837f0d2b45527db4e60087b4221",
"assets/packages/country_flags/res/si/io.si": "3469f709b852fa25f3d735d4e7ee88a2",
"assets/packages/country_flags/res/si/iq.si": "a0be6279c1905893dcbcbe0c7ce44302",
"assets/packages/country_flags/res/si/ir.si": "84eb55b574dd390d8fc86b185d182578",
"assets/packages/country_flags/res/si/is.si": "6a75ef472e3b3674cb992a6c1a2d8656",
"assets/packages/country_flags/res/si/it.si": "c472c6bc7844cc6633d4e41d139b282c",
"assets/packages/country_flags/res/si/je.si": "5fb5c37d3e7469ad537882debd8c4f33",
"assets/packages/country_flags/res/si/jm.si": "db4e387e95c824cefb80b16ae8f8af9f",
"assets/packages/country_flags/res/si/jo.si": "3c4f0683e2fe5e5d9b1424a5865c1e59",
"assets/packages/country_flags/res/si/jp.si": "ee22ac07312690001d82c27ed0fab0a8",
"assets/packages/country_flags/res/si/ke.si": "87ce4c55414a8c5d29f23ca16310a01c",
"assets/packages/country_flags/res/si/kg.si": "1f1f0daac400da3f36e873982f002844",
"assets/packages/country_flags/res/si/kh.si": "711d8494963708be2a01a1dfc5a002db",
"assets/packages/country_flags/res/si/ki.si": "80c4adc8b03b18055be571a612fa3f79",
"assets/packages/country_flags/res/si/km.si": "6cc50d7456a351984bae778298741591",
"assets/packages/country_flags/res/si/kn.si": "cd16cb0ce86ecb131422414a132352bb",
"assets/packages/country_flags/res/si/kp.si": "863f41ba80f1b3f9c794aaeafafb02d6",
"assets/packages/country_flags/res/si/kr.si": "0fc0217454ce0fac5d5b0ed0e19051ce",
"assets/packages/country_flags/res/si/kw.si": "fae7c5f1138fcb68b76b6bf1ecb5f422",
"assets/packages/country_flags/res/si/ky.si": "498424ad28f6c9e005ae14e8d66c3e2f",
"assets/packages/country_flags/res/si/kz.si": "f5aad35a9ce49a2a17f165d4761d8ace",
"assets/packages/country_flags/res/si/la.si": "161dccf57b198768b6c95fd585966156",
"assets/packages/country_flags/res/si/lb.si": "d2268cc1967d63699bb1ff2a87264c75",
"assets/packages/country_flags/res/si/lc.si": "981c9cb18294152ac0423aa64039f6e0",
"assets/packages/country_flags/res/si/li.si": "08d65db7ba158c62f8b70240985fbbe9",
"assets/packages/country_flags/res/si/lk.si": "c8f0c394d54b1618603d89307e6cd127",
"assets/packages/country_flags/res/si/lr.si": "8ea704b8b395abcb8dbd13a7fb738b3e",
"assets/packages/country_flags/res/si/ls.si": "f469f1632ad300b4fb00db8328f9b844",
"assets/packages/country_flags/res/si/lt.si": "8ef10e2712fa997ca06742fc1d79c095",
"assets/packages/country_flags/res/si/lu.si": "0ac3af11df6af8b90ca8f8078902fc9a",
"assets/packages/country_flags/res/si/lv.si": "d61111f2dcbc8b2c84e644f7288b1fd7",
"assets/packages/country_flags/res/si/ly.si": "b99bf6af3ded37ca4b35c612bfe98721",
"assets/packages/country_flags/res/si/ma.si": "9ced8447a0a9b2e720d870bc5aef87cf",
"assets/packages/country_flags/res/si/mc.si": "0cb03fed360c4c1401b0e9cff5dea505",
"assets/packages/country_flags/res/si/md.si": "074b41437a23811d27d4db98bedd56d8",
"assets/packages/country_flags/res/si/me.si": "d87206186e9601dcfabdd0d38b655899",
"assets/packages/country_flags/res/si/mf.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/mg.si": "f6406a9d332acb29115b31235c49c920",
"assets/packages/country_flags/res/si/mh.si": "88c8196c37481de5021237e01ccb95a1",
"assets/packages/country_flags/res/si/mk.si": "0aee6cc90fb321101c9d4afd923c2d85",
"assets/packages/country_flags/res/si/ml.si": "e583b41ed5e4f9508970265999bf47bf",
"assets/packages/country_flags/res/si/mm.si": "3ab23c7fcc44e249de75e6019af32611",
"assets/packages/country_flags/res/si/mn.si": "d7d59010e2822958f8390d72bfbf0072",
"assets/packages/country_flags/res/si/mo.si": "4a369319962984183cfed7f0bf4d60a5",
"assets/packages/country_flags/res/si/mp.si": "48f591d6c4a1e7aab511bcc750536836",
"assets/packages/country_flags/res/si/mq.si": "b319560213233391af1170881595344f",
"assets/packages/country_flags/res/si/mr.si": "73d5e7f3158beeb1e09e294cc2cc3b79",
"assets/packages/country_flags/res/si/ms.si": "e04ef3545afb3927de3aff13640ff6b9",
"assets/packages/country_flags/res/si/mt.si": "2c7e94cc8b51a7ce1c1958a00f880398",
"assets/packages/country_flags/res/si/mu.si": "9f4070ad133e7380edb48cb11cffaef1",
"assets/packages/country_flags/res/si/mv.si": "47d6de70a92bb16bc0284187d12dfb47",
"assets/packages/country_flags/res/si/mw.si": "529e2edb7b4f71261a4d8c52de450f5d",
"assets/packages/country_flags/res/si/mx.si": "add64001e4e654f95a36c24e5b212b80",
"assets/packages/country_flags/res/si/my.si": "017ea1b80814ba715985331e8ff494fc",
"assets/packages/country_flags/res/si/mz.si": "65389bae62f6de08c93ff93fe61e7b24",
"assets/packages/country_flags/res/si/na.si": "d49f748db27e5d6f63293f41c2e8361e",
"assets/packages/country_flags/res/si/nc.si": "8760c0e60c7ab868ea1577de40a8dd04",
"assets/packages/country_flags/res/si/ne.si": "5323700b3b0dc68916ffe048c4afc2b1",
"assets/packages/country_flags/res/si/nf.si": "1473b829023248dbbd77f49b9e6e5ede",
"assets/packages/country_flags/res/si/ng.si": "d2764e808010a6d2389cfc1e83e3b710",
"assets/packages/country_flags/res/si/ni.si": "8af49cf35b72204052de6fab8322afc8",
"assets/packages/country_flags/res/si/nl.si": "130b5b1f64baa8e002dc668b0d3d589f",
"assets/packages/country_flags/res/si/no.si": "6b6efedb50f0a7b05a9afe882924fe99",
"assets/packages/country_flags/res/si/np.si": "aac703fec2d68d1f05f0b368bcd05b5c",
"assets/packages/country_flags/res/si/nr.si": "7762af79a081de69557b7611eaf93bf9",
"assets/packages/country_flags/res/si/nu.si": "dac0a569e83a73006b8600fa1f1f8ac5",
"assets/packages/country_flags/res/si/nz.si": "95a431faf2077c36c314e060d3565e11",
"assets/packages/country_flags/res/si/om.si": "8d23e422f6191c117e764aa17c80e195",
"assets/packages/country_flags/res/si/pa.si": "3231c2af8957eddd456819783df37ef5",
"assets/packages/country_flags/res/si/pe.si": "978e662d337e34163ef3dbc28cf35f11",
"assets/packages/country_flags/res/si/pf.si": "29e59d85bfa9cc1ed50424098c4577b5",
"assets/packages/country_flags/res/si/pg.si": "51e824f62d970ad02c7afa9cc70330d8",
"assets/packages/country_flags/res/si/ph.si": "c8899c0eb2232931f49fa35de57f5d09",
"assets/packages/country_flags/res/si/pk.si": "afa64ff88820436b4ec66b1043a1ca7d",
"assets/packages/country_flags/res/si/pl.si": "034643869bc1b14ad2af44cc9aa24b9f",
"assets/packages/country_flags/res/si/pm.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/pn.si": "4df57b8f366ab9d559a134e25fa92201",
"assets/packages/country_flags/res/si/pr.si": "ccb19936defb882dea166d865f8ee5ff",
"assets/packages/country_flags/res/si/ps.si": "e91b4cc92cc8629f42c9d8fb11d028ba",
"assets/packages/country_flags/res/si/pt.si": "04c1755d12a50d7524a66124c8d725cc",
"assets/packages/country_flags/res/si/pw.si": "e658e7c8cdf0e27c4d9ccb084768f383",
"assets/packages/country_flags/res/si/py.si": "a05eb3d105fde5507180087464bc282b",
"assets/packages/country_flags/res/si/qa.si": "534abea02d79321b510b2a3fb040ffbc",
"assets/packages/country_flags/res/si/re.si": "b319560213233391af1170881595344f",
"assets/packages/country_flags/res/si/ro.si": "ec81c7e1014f2b8584ddd07d0fad9c43",
"assets/packages/country_flags/res/si/rs.si": "f231dce72ce3243a624eb723d200a63e",
"assets/packages/country_flags/res/si/ru.si": "677089233d82298520fd2b176f8003a8",
"assets/packages/country_flags/res/si/rw.si": "8b075359fc5a06224acf83d24b058752",
"assets/packages/country_flags/res/si/sa.si": "cf93fcbb04c97fac13136e80fd27ade9",
"assets/packages/country_flags/res/si/sb.si": "b6160f674954161619f0f57d4039e010",
"assets/packages/country_flags/res/si/sc.si": "65a3e456a8f0cfb400f7a4b354fd1839",
"assets/packages/country_flags/res/si/sd.si": "c6e5b30fafc73d2d84b45a10c6053568",
"assets/packages/country_flags/res/si/se.si": "64f75927796e3bcf418a7f1bce12cf39",
"assets/packages/country_flags/res/si/sg.si": "3e20b9387970793f6b3db62609820d4a",
"assets/packages/country_flags/res/si/sh.si": "084b17449dd0ba76474f133039ee68d3",
"assets/packages/country_flags/res/si/si.si": "11367d866b110a2971aae42dbc72b47f",
"assets/packages/country_flags/res/si/sj.si": "04dcac0249ab5999520c35c8e7f3ce38",
"assets/packages/country_flags/res/si/sk.si": "009a8dbaf2bc675683650d84bde81643",
"assets/packages/country_flags/res/si/sl.si": "a0d669d7821909f6b73d73ebd29e77e7",
"assets/packages/country_flags/res/si/sm.si": "e29d9a0493a72947dfc5e5668bcdcc30",
"assets/packages/country_flags/res/si/sn.si": "e283672331f67926294d3609b6317d82",
"assets/packages/country_flags/res/si/so.si": "ee4702222805ec60fe47cca5500fced8",
"assets/packages/country_flags/res/si/sr.si": "c996e0d2b46e4afc13b18a5abe492fe7",
"assets/packages/country_flags/res/si/ss.si": "cd22425520f63dac39be3dbfdb49465b",
"assets/packages/country_flags/res/si/st.si": "201fdb14910faacd6ce8c30c0a2c1bec",
"assets/packages/country_flags/res/si/sv.si": "912cc0a01ad6e839db6392ece5736b68",
"assets/packages/country_flags/res/si/sx.si": "424c70f52c10927bd40135e75d958e8b",
"assets/packages/country_flags/res/si/sy.si": "744af358ea4a3b27e1ae16c99181dd71",
"assets/packages/country_flags/res/si/sz.si": "780a7eb9794bd6cf85d59d42766e62b3",
"assets/packages/country_flags/res/si/ta.si": "084b17449dd0ba76474f133039ee68d3",
"assets/packages/country_flags/res/si/tc.si": "78d2718e865371288caf216fb083c8bd",
"assets/packages/country_flags/res/si/td.si": "7fe532f134f64c198cc8b4feb90efcaf",
"assets/packages/country_flags/res/si/tf.si": "2fdcf8c49f0b17d65aa2601d4b505cfa",
"assets/packages/country_flags/res/si/tg.si": "2a23d4dbc913968f6eb97dbb5454941e",
"assets/packages/country_flags/res/si/th.si": "1654e97b82bcdcdaade71e1bc3a5590d",
"assets/packages/country_flags/res/si/tj.si": "ff5523df78dbb97dbc212adec3b67a5e",
"assets/packages/country_flags/res/si/tk.si": "9fc0141c9928734e4229f05d2f2f68d4",
"assets/packages/country_flags/res/si/tl.si": "307e25e1507c3e76df867108079cb487",
"assets/packages/country_flags/res/si/tm.si": "61cac086e156158fe52394aadb734bd1",
"assets/packages/country_flags/res/si/tn.si": "d15a30567010db55d9a398ffde25694c",
"assets/packages/country_flags/res/si/to.si": "999f5edc1d7bd74937dab96f8d035368",
"assets/packages/country_flags/res/si/tr.si": "3bd279bd1f4c26e0ad0abed7fb744df3",
"assets/packages/country_flags/res/si/tt.si": "6550348a507c01feaf93fd191503ce72",
"assets/packages/country_flags/res/si/tv.si": "7e462e7d6fa8bdd967bf9e37b86d0906",
"assets/packages/country_flags/res/si/tw.si": "7bba519f0f26cca5417d8edb57bdef83",
"assets/packages/country_flags/res/si/tz.si": "643850342b81b7015ad57cddc9589a69",
"assets/packages/country_flags/res/si/ua.si": "aeb59a31627c7e9cb89c2c31c8b95d15",
"assets/packages/country_flags/res/si/ug.si": "b5368d2d0a873dd2ff8adc689c6c6b09",
"assets/packages/country_flags/res/si/um.si": "bec8665843b879da2d8ed65532da7e01",
"assets/packages/country_flags/res/si/un.si": "d3a2546a132b2e216aa17ffafaca8f57",
"assets/packages/country_flags/res/si/us.si": "a524142e2a2f7df4ee1b26a98f09a927",
"assets/packages/country_flags/res/si/uy.si": "8163529e4c65d4f7f97dad78c51918c7",
"assets/packages/country_flags/res/si/uz.si": "9141032bde5150e86cd2d159c4f31b72",
"assets/packages/country_flags/res/si/va.si": "c23d81f5e4e3acd336ce01d9ed561ee8",
"assets/packages/country_flags/res/si/vc.si": "a6d41b2c67d49f3f202dc920ad2f8c49",
"assets/packages/country_flags/res/si/ve.si": "e846876f7ec7ad396e58fb20e969a486",
"assets/packages/country_flags/res/si/vg.si": "de1ed29316c1d0f81af9946e35d254d7",
"assets/packages/country_flags/res/si/vi.si": "acbfd08b5cd096eac556c46efecb7926",
"assets/packages/country_flags/res/si/vn.si": "5e53b20018d53d957714d0211c237211",
"assets/packages/country_flags/res/si/vu.si": "54ccd51f720f6bb242f2256626a172b8",
"assets/packages/country_flags/res/si/wf.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/ws.si": "1644f5c199bfc4a5ee49d0907eb26efa",
"assets/packages/country_flags/res/si/xk.si": "967bec40d36ab8264262777667c5da33",
"assets/packages/country_flags/res/si/xx.si": "95362a356a59ae95c73b1a7a415abff6",
"assets/packages/country_flags/res/si/ye.si": "cc3bd4c5b25155d249015f88380a3023",
"assets/packages/country_flags/res/si/yt.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/za.si": "a66971379a3a65b274a702c82b3375d7",
"assets/packages/country_flags/res/si/zm.si": "ef4d9e8828b6609e41642a3fbb6541ec",
"assets/packages/country_flags/res/si/zw.si": "b32c711b08bfe7425d509407c48ee5ed",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6a3ee3ac829708eb2f38e77b43ac8371",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "c6ac80bdc5b2896345377c9439f91d54",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "2f141ffd94f3ef0ed716615fd537e708",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "0ebc4e7ca5e040da671730a59b181135",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"canvaskit/canvaskit.js": "76f7d822f42397160c5dfc69cbc9b2de",
"canvaskit/canvaskit.wasm": "f48eaf57cada79163ec6dec7929486ea",
"canvaskit/chromium/canvaskit.js": "8c8392ce4a4364cbb240aa09b5652e05",
"canvaskit/chromium/canvaskit.wasm": "fc18c3010856029414b70cae1afc5cd9",
"canvaskit/skwasm.js": "1df4d741f441fa1a4d10530ced463ef8",
"canvaskit/skwasm.wasm": "6711032e17bf49924b2b001cef0d3ea3",
"canvaskit/skwasm.worker.js": "19659053a277272607529ef87acf9d8a",
"favicon.png": "14d8be3e9dfb3e29ce227e0a6f4f7beb",
"firebase-messaging-sw.js": "2012b3643653af5734691c74e73de0f5",
"flutter.js": "6b515e434cea20006b3ef1726d2c8894",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/ICON_UNILINK-03.png": "3f4b669611bca83b83925220bcdf09ca",
"icons/uniLinkIcon2.3-03.png": "905805341a5b2c4b1f3631d7c90040f5",
"index.html": "70c43e0617addaac58dba52d031b1962",
"/": "70c43e0617addaac58dba52d031b1962",
"main.dart.js": "1cf8f6fe598ed53e6fc73891633fcbd6",
"manifest.json": "45853877881495375c90a492fa289108",
"version.json": "92569d41b50b2f3b26b1686465e0b307"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
