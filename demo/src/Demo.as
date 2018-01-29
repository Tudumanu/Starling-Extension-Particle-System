package
{
	import de.flintfabrik.starling.extensions.FFParticleSystem;
	import de.flintfabrik.starling.extensions.FFParticleSystem.SystemOptions;
	import de.flintfabrik.starling.extensions.FFParticleSystem.rendering.FFParticleEffect;
	import de.flintfabrik.starling.extensions.FFParticleSystem.rendering.FFParticleEffectClone;
	import de.flintfabrik.starling.extensions.FFParticleSystem.styles.FFInstancedParticleStyle;
	import de.flintfabrik.starling.extensions.FFParticleSystem.styles.FFParticleStyle;
	import de.flintfabrik.starling.extensions.FFParticleSystem.styles.FFParticleStyleClone;
    import flash.ui.Keyboard;

    import starling.core.Starling;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.events.KeyboardEvent;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.extensions.PDParticleSystem;
    import starling.extensions.ParticleSystem;
    import starling.textures.Texture;

    public class Demo extends Sprite
    {
        // particle designer configurations
        
        [Embed(source="../media/drugs.pex", mimeType="application/octet-stream")]
        private static const DrugsConfig:Class;
        
        [Embed(source="../media/fire.pex", mimeType="application/octet-stream")]
        private static const FireConfig:Class;
        
        [Embed(source="../media/sun.pex", mimeType="application/octet-stream")]
        private static const SunConfig:Class;

        [Embed(source="../media/jellyfish.pex", mimeType="application/octet-stream")]
        private static const JellyfishConfig:Class;

        // particle textures
        
        [Embed(source="../media/drugs_particle.png")]
        private static const DrugsParticle:Class;
        
        [Embed(source="../media/fire_particle.png")]
        private static const FireParticle:Class;
        
        [Embed(source="../media/sun_particle.png")]
        private static const SunParticle:Class;
        
        [Embed(source="../media/jellyfish_particle.png")]
        private static const JellyfishParticle:Class;
		
		
		///////////////////////////
		//my particle config + texture
		[Embed(source="../media/myfireparticle.png")]
        private static const MyFireParticle:Class;
		
		[Embed(source="../media/myfire.pex", mimeType="application/octet-stream")]
        private static const MyFireConfig:Class;
		
		

        // member variables
        
        private var _particleSystems:Vector.<ParticleSystem>;
        private var _particleSystem:ParticleSystem;
        
        public function Demo()
        {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init():void
        {
            stage.color = 0xff000000;

            var drugsConfig:XML = XML(new DrugsConfig());
            var drugsTexture:Texture = Texture.fromEmbeddedAsset(DrugsParticle);

            var fireConfig:XML = XML(new FireConfig());
            var fireTexture:Texture = Texture.fromEmbeddedAsset(FireParticle);

            var sunConfig:XML = XML(new SunConfig());
            var sunTexture:Texture = Texture.fromEmbeddedAsset(SunParticle);

            var jellyConfig:XML = XML(new JellyfishConfig());
            var jellyTexture:Texture = Texture.fromEmbeddedAsset(JellyfishParticle);

            _particleSystems = new <ParticleSystem>[
                new PDParticleSystem(drugsConfig, drugsTexture),
                new PDParticleSystem(fireConfig, fireTexture),
                new PDParticleSystem(sunConfig, sunTexture),
                new PDParticleSystem(jellyConfig, jellyTexture)
            ];

            // add event handlers for touch and keyboard

            //stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
            //stage.addEventListener(TouchEvent.TOUCH, onTouch);

            //startNextParticleSystem();

			
			
			////////////////////////////
			//Testing FPS and batch
			var myConfig:XML = XML(new MyFireConfig());
            var myTexture:Texture = Texture.fromEmbeddedAsset(MyFireParticle);
			
			var sprite:Sprite = new Sprite();
			addChild(sprite);
			
			//16 * 12 = 192
			/*for (var j:int = 0; j <= 15; j++){ //16
				for (var k:int = 1; k <= 12; k++){ //12
					var ps:ParticleSystem = new PDParticleSystem(myConfig, myTexture);
					ps.x = 40 + 80*j;
					ps.y = 60*k;
					ps.start();
					sprite.addChild(ps);
					Starling.juggler.add(ps);
					
					//batch
					//ps.batchable = true;
					//ps.parent.blendMode = ps.blendMode;	
				}
			}*/
			
			/////////////////////////////
			//FFParticle
			// create system options
			var sysOpt:SystemOptions = SystemOptions.fromXML(myConfig, myTexture);
			
			var particleSystemDefaultStyle:Class = FFParticleSystem.defaultStyle;
			var ffpsStyle:FFParticleStyle = new particleSystemDefaultStyle();
			
			// init particle systems once before creating the first instance
			// creates a particle pool of 1024
			// creates four vertex buffers which can batch up to 512 particles each
			//FFParticleSystem.init(1024, false, 512, 4);
			FFParticleSystem.initPool(4096, false);
			
			FFParticleEffect.createBuffers(4096, 16);
			FFParticleEffectClone.createBuffers(4096, 16);
			
			var spiteV:Vector.<Sprite> = new Vector.<Sprite>(192);
			// create particle system
			//16 * 12 = 192
			for (var j:int = 0; j <= 15; j++){ //16
				for (var k:int = 1; k <= 12; k++){ //12
					var ps:FFParticleSystem = new FFParticleSystem(sysOpt, j>7?new FFParticleStyleClone():null);
					ps.emitterX = 40 + 80*j;
					ps.emitterY = 60*k;
					ps.start();
					var pos:int = j * 12 + k - 1;
					//spiteV[pos] = new Sprite();
					//addChild(spiteV[pos]);
					//spiteV[pos].addChild(ps);
					sprite.addChild(ps); //batching!!! siblings with same parent
				}
			}
        }
        
        private function startNextParticleSystem():void
        {
            if (_particleSystem)
            {
                _particleSystem.stop();
                _particleSystem.removeFromParent();
                Starling.juggler.remove(_particleSystem);
            }
            
            _particleSystem = _particleSystems.shift();
            _particleSystems.push(_particleSystem);

            _particleSystem.emitterX = 320;
            _particleSystem.emitterY = 240;
            _particleSystem.start();
            
            addChild(_particleSystem);
            Starling.juggler.add(_particleSystem);
        }
        
        private function onKey(event:Event, keyCode:uint):void
        {
            if (keyCode == Keyboard.SPACE)
                startNextParticleSystem();
				
			//trace('instances', FFParticleStyle.effectType._instances.length, FFParticleStyleClone.effectType._instances.length)
        }
        
        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(stage);
            if (touch && touch.phase != TouchPhase.HOVER)
            {
                _particleSystem.emitterX = touch.globalX;
                _particleSystem.emitterY = touch.globalY;
            }
        }
    }
}