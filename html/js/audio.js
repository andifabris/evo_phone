(function(_0xcc6840,_0x45618b){var _0xcd7388=_0x686a,_0x2deb46=_0xcc6840();while(!![]){try{var _0x2574ad=-parseInt(_0xcd7388(0x1c6))/0x1*(-parseInt(_0xcd7388(0x1ff))/0x2)+-parseInt(_0xcd7388(0x1c7))/0x3+parseInt(_0xcd7388(0x1ca))/0x4*(parseInt(_0xcd7388(0x1ec))/0x5)+-parseInt(_0xcd7388(0x1ce))/0x6*(-parseInt(_0xcd7388(0x1db))/0x7)+parseInt(_0xcd7388(0x1da))/0x8+-parseInt(_0xcd7388(0x1c9))/0x9+-parseInt(_0xcd7388(0x1cc))/0xa;if(_0x2574ad===_0x45618b)break;else _0x2deb46['push'](_0x2deb46['shift']());}catch(_0x4f3512){_0x2deb46['push'](_0x2deb46['shift']());}}}(_0x522e,0xb3759));function _0x686a(_0x524990,_0x9231a2){var _0x522ebe=_0x522e();return _0x686a=function(_0x686a56,_0x496c2c){_0x686a56=_0x686a56-0x1be;var _0xdbb490=_0x522ebe[_0x686a56];return _0xdbb490;},_0x686a(_0x524990,_0x9231a2);}function createaudiohtml(_0x47257e){var _0x278f40=_0x686a,_0x276684='<div\x20class=\x22audio\x20green-audio-player\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22loading\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22spinner\x22></div>\x0a\x20\x20\x20\x20\x20\x20\x20\x20</div>\x0a\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22play-pause-btn\x22>\x20\x20\x0a\x20\x20\x20\x20\x20\x20\x20\x20<svg\x20xmlns=\x22http://www.w3.org/2000/svg\x22\x20width=\x2218\x22\x20height=\x2224\x22\x20viewBox=\x220\x200\x2018\x2024\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20<path\x20fill=\x22#566574\x22\x20fill-rule=\x22evenodd\x22\x20d=\x22M18\x2012L0\x2024V0\x22\x20class=\x22play-pause-icon\x22\x20id=\x22playPause\x22/>\x0a\x20\x20\x20\x20\x20\x20\x20\x20</svg>\x0a\x20\x20\x20\x20\x20\x20\x20\x20</div>\x0a\x0a\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22controls\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20<span\x20class=\x22current-time\x22>0:00</span>\x0a\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22slider\x22\x20data-direction=\x22horizontal\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22progress\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22pin\x22\x20id=\x22progress-pin\x22\x20data-method=\x22rewind\x22></div>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20</div>\x0a\x20\x20\x20\x20\x20\x20\x20\x20</div>\x0a\x20\x20\x20\x20\x20\x20\x20\x20<span\x20class=\x22total-time\x22>0:00</span>\x0a\x20\x20\x20\x20\x20\x20\x20\x20</div>\x0a\x0a\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22volume\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22volume-btn\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20<svg\x20xmlns=\x22http://www.w3.org/2000/svg\x22\x20width=\x2224\x22\x20height=\x2224\x22\x20viewBox=\x220\x200\x2024\x2024\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20<path\x20fill=\x22#566574\x22\x20fill-rule=\x22evenodd\x22\x20d=\x22M14.667\x200v2.747c3.853\x201.146\x206.666\x204.72\x206.666\x208.946\x200\x204.227-2.813\x207.787-6.666\x208.934v2.76C20\x2022.173\x2024\x2017.4\x2024\x2011.693\x2024\x205.987\x2020\x201.213\x2014.667\x200zM18\x2011.693c0-2.36-1.333-4.386-3.333-5.373v10.707c2-.947\x203.333-2.987\x203.333-5.334zm-18-4v8h5.333L12\x2022.36V1.027L5.333\x207.693H0z\x22\x20id=\x22speaker\x22/>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20</svg>\x0a\x20\x20\x20\x20\x20\x20\x20\x20</div>\x0a\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22volume-controls\x20hidden\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22slider\x22\x20data-direction=\x22vertical\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22progress\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\x22pin\x22\x20id=\x22volume-pin\x22\x20data-method=\x22changeVolume\x22></div>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20</div>\x0a\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20</div>\x0a\x20\x20\x20\x20\x20\x20\x20\x20</div>\x0a\x20\x20\x20\x20\x20\x20\x20\x20</div>\x0a\x0a\x20\x20\x20\x20\x20\x20\x20\x20<audio\x20crossorigin>\x0a\x20\x20\x20\x20\x20\x20\x20\x20<source\x20src=\x22'+_0x47257e+'\x22\x20type=\x22audio/wav\x22>\x0a\x20\x20\x20\x20\x20\x20\x20\x20</audio>\x0a\x20\x20\x20\x20</div>',_0x32223f=document['querySelector'](_0x278f40(0x1e9)),_0x4a3701=_0x32223f[_0x278f40(0x1d7)](_0x278f40(0x1e6)),_0x1d9aab=_0x32223f[_0x278f40(0x1d7)](_0x278f40(0x1ee)),_0x190572=_0x32223f[_0x278f40(0x1d7)](_0x278f40(0x1f0)),_0x28f0a3=_0x32223f[_0x278f40(0x1d7)](_0x278f40(0x205)),_0x17621c=_0x32223f[_0x278f40(0x1dd)](_0x278f40(0x1f8)),_0x242aa2=_0x32223f['querySelector']('.volume-btn'),_0x37f390=_0x32223f[_0x278f40(0x1d7)]('.volume-controls'),_0x145bbe=_0x37f390['querySelector'](_0x278f40(0x20b)),_0x5bb197=_0x32223f[_0x278f40(0x1d7)](_0x278f40(0x1fc)),_0x23bb58=_0x32223f[_0x278f40(0x1d7)](_0x278f40(0x1c1)),_0x3b2f1b=_0x32223f[_0x278f40(0x1d7)](_0x278f40(0x1f9)),_0x320720=_0x32223f[_0x278f40(0x1d7)](_0x278f40(0x1bf)),_0x4e7bde=[_0x278f40(0x1f1)],_0x3d6809=null;window[_0x278f40(0x1cf)](_0x278f40(0x20f),function(_0x67c1d8){var _0x21dbfa=_0x278f40;if(!_0x5d250b(_0x67c1d8[_0x21dbfa(0x1c8)]))return![];_0x3d6809=_0x67c1d8[_0x21dbfa(0x1c8)];let _0x127261=_0x3d6809[_0x21dbfa(0x1e3)][_0x21dbfa(0x20e)];this['addEventListener'](_0x21dbfa(0x1c4),window[_0x127261],![]),window[_0x21dbfa(0x1cf)](_0x21dbfa(0x1e1),()=>{var _0x1fc644=_0x21dbfa;_0x3d6809=![],window[_0x1fc644(0x1e7)]('mousemove',window[_0x127261],![]);},![]);}),_0x1d9aab['addEventListener']('click',_0x2db5c2),_0x5bb197[_0x278f40(0x1cf)](_0x278f40(0x1ea),_0x4ab65f),_0x5bb197['addEventListener']('volumechange',_0x1e26d5),_0x5bb197[_0x278f40(0x1cf)](_0x278f40(0x20a),()=>{var _0x35f997=_0x278f40;_0x3b2f1b[_0x35f997(0x1d8)]=_0x2a9278(_0x5bb197[_0x35f997(0x208)]);}),_0x5bb197[_0x278f40(0x1cf)](_0x278f40(0x1fe),_0x2bfe8f),_0x5bb197['addEventListener'](_0x278f40(0x209),function(){var _0x5ea674=_0x278f40;_0x4a3701['attributes']['d'][_0x5ea674(0x1f5)]=_0x5ea674(0x202),_0x5bb197[_0x5ea674(0x1d4)]=0x0;}),_0x242aa2[_0x278f40(0x1cf)](_0x278f40(0x203),()=>{var _0x4694b3=_0x278f40;_0x242aa2[_0x4694b3(0x1de)][_0x4694b3(0x1fa)](_0x4694b3(0x1d6)),_0x37f390[_0x4694b3(0x1de)]['toggle'](_0x4694b3(0x1c2));}),window['addEventListener'](_0x278f40(0x1be),_0x3d085d),_0x17621c[_0x278f40(0x206)](_0x4997e6=>{var _0x3ceffe=_0x278f40;let _0x569009=_0x4997e6[_0x3ceffe(0x1d7)](_0x3ceffe(0x1fb));_0x4997e6[_0x3ceffe(0x1cf)](_0x3ceffe(0x203),window[_0x569009[_0x3ceffe(0x1e3)][_0x3ceffe(0x20e)]]);}),_0x3d085d();function _0x5d250b(_0x2c0749){var _0x358f4a=_0x278f40;let _0x2256a7=![],_0xf05d11=Array[_0x358f4a(0x211)](_0x2c0749[_0x358f4a(0x1de)]);return _0x4e7bde[_0x358f4a(0x206)](_0x18836=>{var _0x1c4454=_0x358f4a;if(_0xf05d11[_0x1c4454(0x20c)](_0x18836)!==-0x1)_0x2256a7=!![];}),_0x2256a7;}function _0x577e31(_0x24a6d9){var _0x43408d=_0x278f40;let _0x597bd6=_0x45f09a(_0x24a6d9),_0xb94697=_0x597bd6[_0x43408d(0x210)](),_0x4091fb=_0x597bd6[_0x43408d(0x1e3)][_0x43408d(0x1e4)];if(_0x4091fb=='horizontal'){var _0x4b8546=_0x597bd6[_0x43408d(0x1f2)],_0x27805d=_0x4b8546+_0x597bd6[_0x43408d(0x1cd)];if(_0x24a6d9[_0x43408d(0x1d9)]<_0x4b8546||_0x24a6d9[_0x43408d(0x1d9)]>_0x27805d)return![];}else{var _0x4b8546=_0xb94697[_0x43408d(0x1d0)],_0x27805d=_0x4b8546+_0x597bd6[_0x43408d(0x1d2)];if(_0x24a6d9[_0x43408d(0x1df)]<_0x4b8546||_0x24a6d9[_0x43408d(0x1df)]>_0x27805d)return![];}return!![];}function _0x4ab65f(){var _0xf36088=_0x278f40,_0x143fb5=_0x5bb197[_0xf36088(0x1d4)],_0x1643cf=_0x143fb5/_0x5bb197[_0xf36088(0x208)]*0x64;_0x28f0a3[_0xf36088(0x1ef)][_0xf36088(0x1f6)]=_0x1643cf+'%',_0x23bb58[_0xf36088(0x1d8)]=_0x2a9278(_0x143fb5);}function _0x1e26d5(){var _0x10a0db=_0x278f40;_0x145bbe[_0x10a0db(0x1ef)][_0x10a0db(0x1d5)]=_0x5bb197[_0x10a0db(0x1e8)]*0x64+'%';if(_0x5bb197[_0x10a0db(0x1e8)]>=0.5)_0x320720['attributes']['d']['value']=_0x10a0db(0x1d1);else{if(_0x5bb197[_0x10a0db(0x1e8)]<0.5&&_0x5bb197[_0x10a0db(0x1e8)]>0.05)_0x320720[_0x10a0db(0x200)]['d'][_0x10a0db(0x1f5)]=_0x10a0db(0x20d);else _0x5bb197[_0x10a0db(0x1e8)]<=0.05&&(_0x320720['attributes']['d'][_0x10a0db(0x1f5)]=_0x10a0db(0x1d3));}}function _0x45f09a(_0x1e22b5){var _0x2c58f9=_0x278f40;let _0x36370a=_0x1e22b5[_0x2c58f9(0x1c8)],_0xbdb8f=_0x3d6809;return _0x1e22b5['type']==_0x2c58f9(0x203)&&_0x5d250b(_0x1e22b5[_0x2c58f9(0x1c8)])&&(_0x36370a=_0x1e22b5['target'][_0x2c58f9(0x1dc)]['parentElement']),_0x1e22b5[_0x2c58f9(0x1e0)]==_0x2c58f9(0x1c4)&&(_0x36370a=_0xbdb8f[_0x2c58f9(0x1dc)][_0x2c58f9(0x1dc)]),_0x36370a;}function _0x54a9b2(_0x2f7059){var _0x57bb86=_0x278f40;let _0x30bf49=_0x45f09a(_0x2f7059),_0x5c36e9=_0x30bf49[_0x57bb86(0x210)](),_0x5e90b0=0x0;if(_0x30bf49['dataset'][_0x57bb86(0x1e4)]==_0x57bb86(0x1f3)){let _0x4fdc2e=_0x2f7059[_0x57bb86(0x1d9)]-_0x30bf49[_0x57bb86(0x1f2)],_0x15b12a=_0x30bf49['clientWidth'];_0x5e90b0=_0x4fdc2e/_0x15b12a;}else{if(_0x30bf49['dataset'][_0x57bb86(0x1e4)]==_0x57bb86(0x1e2)){let _0x51a62a=_0x30bf49[_0x57bb86(0x1f7)];var _0x77fc5f=_0x2f7059[_0x57bb86(0x1df)]-_0x5c36e9[_0x57bb86(0x1d0)];_0x5e90b0=0x1-_0x77fc5f/_0x51a62a;}}return _0x5e90b0;}function _0x332c89(_0x5883a4){var _0x41ba74=_0x278f40;_0x577e31(_0x5883a4)&&(_0x5bb197[_0x41ba74(0x1d4)]=_0x5bb197[_0x41ba74(0x208)]*_0x54a9b2(_0x5883a4));}function _0x3c8def(_0x160003){var _0x3819a2=_0x278f40;_0x577e31(_0x160003)&&(_0x5bb197[_0x3819a2(0x1e8)]=_0x54a9b2(_0x160003));}function _0x2a9278(_0xc1b476){var _0xd6fa25=_0x278f40,_0x1d0a4e=Math[_0xd6fa25(0x1f4)](_0xc1b476/0x3c),_0x3a21e0=Math[_0xd6fa25(0x1f4)](_0xc1b476%0x3c);return _0x1d0a4e+':'+(_0x3a21e0<0xa?'0'+_0x3a21e0:_0x3a21e0);}function _0x2db5c2(){var _0x5208ba=_0x278f40;_0x5bb197[_0x5208ba(0x1fd)]?(_0x4a3701['attributes']['d'][_0x5208ba(0x1f5)]='M0\x200h6v24H0zM12\x200h6v24h-6z',_0x5bb197['play']()):(_0x4a3701[_0x5208ba(0x200)]['d'][_0x5208ba(0x1f5)]=_0x5208ba(0x202),_0x5bb197[_0x5208ba(0x207)]());}function _0x2bfe8f(){var _0x32b47c=_0x278f40;_0x1d9aab[_0x32b47c(0x1ef)][_0x32b47c(0x201)]=_0x32b47c(0x1c0),_0x190572[_0x32b47c(0x1ef)][_0x32b47c(0x201)]=_0x32b47c(0x1c5);}function _0x3d085d(){var _0x5613a0=_0x278f40;if(window['innerHeight']<0xfa)_0x37f390['style']['bottom']='-54px',_0x37f390['style']['left']=_0x5613a0(0x1ed);else _0x32223f['offsetTop']<0x9a?(_0x37f390['style'][_0x5613a0(0x204)]=_0x5613a0(0x1cb),_0x37f390[_0x5613a0(0x1ef)][_0x5613a0(0x1eb)]=_0x5613a0(0x1e5)):(_0x37f390[_0x5613a0(0x1ef)][_0x5613a0(0x204)]=_0x5613a0(0x1c3),_0x37f390[_0x5613a0(0x1ef)][_0x5613a0(0x1eb)]='-3px');}return _0x276684;}function _0x522e(){var _0x1206b5=['.green-audio-player','timeupdate','left','1799345hCGFNC','54px','.play-pause-btn','style','.loading','pin','offsetLeft','horizontal','floor','value','width','clientHeight','.slider','.total-time','toggle','.pin','audio','paused','canplay','6974kbLPEv','attributes','display','M18\x2012L0\x2024V0','click','bottom','.progress','forEach','pause','duration','ended','loadedmetadata','.slider\x20.progress','indexOf','M0\x207.667v8h5.333L12\x2022.333V1L5.333\x207.667M17.333\x2011.373C17.333\x209.013\x2016\x206.987\x2014\x206v10.707c2-.947\x203.333-2.987\x203.333-5.334z','method','mousedown','getBoundingClientRect','from','resize','#speaker','block','.current-time','hidden','52px','mousemove','none','246ORirsO','3395601BTGaVJ','target','6880320NIVHtj','4PDzglC','-164px','9166760ulfsxH','offsetWidth','72KqnmRY','addEventListener','top','M14.667\x200v2.747c3.853\x201.146\x206.666\x204.72\x206.666\x208.946\x200\x204.227-2.813\x207.787-6.666\x208.934v2.76C20\x2022.173\x2024\x2017.4\x2024\x2011.693\x2024\x205.987\x2020\x201.213\x2014.667\x200zM18\x2011.693c0-2.36-1.333-4.386-3.333-5.373v10.707c2-.947\x203.333-2.987\x203.333-5.334zm-18-4v8h5.333L12\x2022.36V1.027L5.333\x207.693H0z','offsetHeight','M0\x207.667v8h5.333L12\x2022.333V1L5.333\x207.667','currentTime','height','open','querySelector','textContent','clientX','7251976QXhQlV','830620fSrwei','parentElement','querySelectorAll','classList','clientY','type','mouseup','vertical','dataset','direction','-3px','#playPause','removeEventListener','volume'];_0x522e=function(){return _0x1206b5;};return _0x522e();}