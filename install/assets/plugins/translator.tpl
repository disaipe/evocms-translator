/**
 * Translator
 *
 * Simple service for translating lines in a document for a given placeholder
 *
 * @category	plugin
 * @version		0.1
 * @internal	@properties &folder=Translates folder;string;/translates;/translates &defaultLang=Default language code;string;ru_RU;ru_RU &fallbackLang=Fallback language code;string &cookieName=Cookie name with lang code;string;lang;lang &queryArgName=Query argument name with lang code;string;lang;lang &placeholderRegExp=Placeholder reqular expression;string;/i`(.*?)`/;/i`(.*?)`/;RegExp to replace placeholders
 * @internal	@events OnWebPagePrerender
 * @internal	@disabled 1
 * 
 * @author		https://github.com/disaipe
 */

class Translator {
	private $options;
	private $translates;
	private $current;
	private $fallback;
	private $dir;
	
	function __construct($options) {
		$this->translates = [];
		$this->options = $options;
		
		$this->dir = MODX_BASE_PATH . trim(@$options['dir'] ?: 'translates', '/');
		$this->current = $this->getCurrentLang();
		$this->fallback = @$options['fallback'];

		if ($this->current)
			$this->loadTranslateFiles();
	}
	
	public function translate($content) {
		if (!$this->current)
			return $content;
		
		return preg_replace_callback($this->options['placeholder'], [$this, 'replaceCallback'], $content);
	}
	
	private function getCurrentLang() {
		if (@$this->options['queryArgName']) {
			$queryLang = @$_GET[$this->options['queryArgName']];
			if ($queryLang)
				return $queryLang;
		}
		
		if ($this->options['cookieName']) {
			$cookieLang = @$_COOKIE[$this->options['cookieName']];
			if ($cookieLang)
				return $cookieLang;
		}
		
		if ($this->options['default'])
			return $this->options['default'];	
		
		return false;
	}

	private function loadTranslateFiles() {
		if (is_dir($this->dir)) {
			$dh = opendir($this->dir);

			while (($file = readdir($dh)) !== false) {
				$fullpath = $this->dir . '/' . $file;

				$fileinfo = pathinfo($fullpath);
				$basename = $fileinfo['filename'];
				$extension = $fileinfo['extension'];

				if ($extension === 'php') {
					$langKey = strtolower($basename);
					$this->translates[$langKey] = $this->parseTranslateFile($fullpath);
				}
			}
		}
	}

	private function parseTranslateFile($fullpath) {
		$out = [];

		$content = file_get_contents($fullpath);
		preg_match_all("/^(.*)=(.*[^=]*)$/m", $content, $matches, PREG_SET_ORDER, 0);

		foreach ($matches as $match) {
			$out[trim($match[1])] = $match[2];
		}
		
		return $out;
	}
	
	private function translateFrom($lang, $key) {
		$lang = strtolower($lang);
		if (!array_key_exists($lang, $this->translates))
			return null;
		
		$translates = $this->translates[$lang];
		return @$translates[$key];
	}
	
	private function replaceCallback($matches) {		
		$key = $matches[1];		
		$str = $this->translateFrom($this->current, $key);
		
		if (!$str && $this->fallback)
			$str = $this->translateFrom($this->fallback, $key);
			
		return $str ?: $key;
	}
}

$options = [
	'dir' => $folder,
	'default' => $defaultLang,
	'fallback' => $fallbackLang,
	'cookieName' => $cookieName,
	'queryArgName' => $queryArgName,
	'placeholder' => $placeholderRegExp
];

$content = &$modx->documentOutput;

$translator = new Translator($options);
$content = $translator->translate($content);