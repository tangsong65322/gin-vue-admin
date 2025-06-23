import {
	createClass,
	parseLatex,
	renderMathInText
} from "./index.js"

export function treeToHtml(nodes) {
    // 如果输入是数组，处理数组中的每个节点
    if (Array.isArray(nodes)) {
        return nodes.map(node => treeToHtml(node)).join('');
    }

    // 如果是文本节点
    if (nodes.type === 'text') {
        return nodes.text;
    }

    // 处理HTML节点
    if (nodes.name) {
        // 构建开始标签
        let html = `<${nodes.name}`;

        // 添加属性
        if (nodes.attrs) {
            for (const [key, value] of Object.entries(nodes.attrs)) {
                html += ` ${key}="${value}"`;
            }
        }

        html += '>';

        // 处理子节点
        if (nodes.children) {
            html += treeToHtml(nodes.children);
        }

        // 添加结束标签
        html += `</${nodes.name}>`;

        return html;
    }

    return '';
}

export function markedKatex(katex) {
	'use strict';

	const inlineRule = /^(\${1,2})(?!\$)((?:\\.|[^\\\n])*?(?:\\.|[^\\\n\$]))\1(?=[\s?!\.,:？！。，：]|$)/;
	const inlineRuleNonStandard =
		/^(\${1,2})(?!\$)((?:\\.|[^\\\n])*?(?:\\.|[^\\\n\$]))\1/; // Non-standard, even if there are no spaces before and after $ or $$, try to parse

	const blockRule = /^(\${1,2})\n((?:\\[^]|[^\\])+?)\n\1(?:\n|$)/;

	function index(options = {}) {
		return {
			extensions: [
				inlineKatex(options, createRenderer(options, false)),
				blockKatex(options, createRenderer(options, true)),
			],
		};
	}

	function createRenderer(options, newlineAfter) {

		return (token) => katex.renderToString(token.text, {
			...options,
			displayMode: token.displayMode
		}) + (newlineAfter ? '\n' : '');
	}

	function inlineKatex(options, renderer) {
		const nonStandard = options && options.nonStandard;
		const ruleReg = nonStandard ? inlineRuleNonStandard : inlineRule;
		return {
			name: 'inlineKatex',
			level: 'inline',
			start(src) {
				let index;
				let indexSrc = src;

				while (indexSrc) {
					index = indexSrc.indexOf('$');
					if (index === -1) {
						return;
					}
					const f = nonStandard ? index > -1 : index === 0 || indexSrc.charAt(index - 1) === ' ';
					if (f) {
						const possibleKatex = indexSrc.substring(index);

						if (possibleKatex.match(ruleReg)) {
							return index;
						}
					}

					indexSrc = indexSrc.substring(index + 1).replace(/^\$+/, '');
				}
			},
			tokenizer(src, tokens) {
				const match = src.match(ruleReg);
				if (match) {
					return {
						type: 'inlineKatex',
						raw: match[0],
						text: match[2].trim(),
						displayMode: match[1].length === 2,
					};
				}
			},
			renderer,
		};
	}

	function blockKatex(options, renderer) {
		return {
			name: 'blockKatex',
			level: 'block',
			tokenizer(src, tokens) {
				const match = src.match(blockRule);
				if (match) {
					return {
						type: 'blockKatex',
						raw: match[0],
						text: match[2].trim(),
						displayMode: match[1].length === 2,
					};
				}
			},
			renderer,
		};
	}

	return index;

}