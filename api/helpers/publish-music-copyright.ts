import { publishPackage } from '../sui-utils';

// Publish the music copyright contract to the configured network (default: testnet)
(async () => {
	await publishPackage({
		packagePath: __dirname + '/../../contracts/music_copyright',
		network: 'testnet',
		exportFileName: 'music-copyright',
	});
})();



