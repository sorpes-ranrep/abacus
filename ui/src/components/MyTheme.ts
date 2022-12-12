export const lightColors: any = {
    background: {
        light: "#D3D3D3",
        evenLighter: "#F2F2F2",
        dark: "#A5A5B4",
        accent: "#EB6826",
        lightAccent: "#FFF8CB",
        blue: "rgba(78, 158, 253, 0.12)",
        white: "#FFFFFF",
    },
    text: {
        dark: "#333333",
        medium: "rgba(0, 0, 0, 0.44)",
        lessMedium: "rgba(0, 0, 0, 0.33)",
        black: "#000000",
        blue: "#4E9EFD",
    },
    border: {
        light: "#E1E1E1",
        lighter: "#CACACA",
        differentLight: "rgba(227, 227, 227, 0.7)",
        blue: "#4E9EFD",
    },
};

function invert2DigitHex(hex: string) : string {
    var n: number = 255 - parseInt(hex, 16);
    return `${n < 16 ? "0" : ""}${n.toString(16)}`;
}

function invertColor(color: string) : string {
    if (color[0] === '#' && color.length >= 7) {
        var r: string = invert2DigitHex(color.substring(1, 3));
        var g: string = invert2DigitHex(color.substring(3, 5));
        var b: string = invert2DigitHex(color.substring(5, 7));
        var a: string = color.length === 9 ? color.substring(7, 9) : "";
        return `#${r}${g}${b}${a}`;
    } else if (color.length >= 5 && color.substring(0, 4) === "rgba") {
        var rgba: number[] = color.substring(5, color.length - 1).split(",").map(parseFloat);
        var rn: number = 0, gn: number = 0, bn: number = 0, an: number = 0
        rn = rgba[0];
        gn = rgba[1];
        bn = rgba[2];
        an = rgba[3];
        return `rgba(${255 - rn}, ${255 - gn}, ${255 - bn}, ${an})`;
    }

    return "";
}

function invertColors(colors: any) : any {
    var copy: any = Object.assign({}, colors); 
    for (const key in copy) {
        if (typeof(copy[key]) === "string") {
            copy[key] = invertColor(copy[key]) 
        } else {
            copy[key] = invertColors(copy[key])
        }
    }
    return copy;
}

const darkColorsOverride: any = {
    text: {
        lessMedium: "rgba(127,127,127,0.77)",
        medium: "rgba(127,127,127,0.66)"
    },
    background: {
        white: "#222222",
    }
}

var invertedLight: any = invertColors(lightColors);
if (darkColorsOverride["background"] !== undefined) {
    invertedLight.background = {...(invertedLight.background), ...(darkColorsOverride["background"])};
}
if (darkColorsOverride["text"] !== undefined) {
    invertedLight.text = {...(invertedLight.text), ...(darkColorsOverride["text"])};
}
if (darkColorsOverride["border"] !== undefined) {
    invertedLight.border = {...(invertedLight.border), ...(darkColorsOverride["border"])};
}

export const darkColors = invertedLight;
